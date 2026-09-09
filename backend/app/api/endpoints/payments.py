import hashlib
import hmac
import base64
import uuid
from datetime import datetime
from urllib.parse import quote

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse, HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import joinedload
from pydantic import BaseModel as PydanticBaseModel

from app.db.session import get_db
from app.schemas.common import APIResponse
from app.models.order import Order
from app.models.product import Product
from app.models.extras import Payment
from app.models.user import User
from app.core.config import settings
from app.api.deps import get_current_user, get_current_admin

router = APIRouter()


# ──────────────────────────────────────────────
# 1. Payment Methods
# ──────────────────────────────────────────────

@router.get("/payment-methods", response_model=APIResponse[list])
async def get_payment_methods():
    return APIResponse(data=[
        {"id": "click", "name": {"en": "Click", "ru": "Click", "uz": "Click"}},
        {"id": "payme", "name": {"en": "Payme", "ru": "Payme", "uz": "Payme"}}
    ])


# ──────────────────────────────────────────────
# 2. Process Payment — generate checkout URL
# ──────────────────────────────────────────────

class ProcessPaymentRequest(PydanticBaseModel):
    order_id: str
    payment_method_id: str


@router.post("/process", response_model=APIResponse[dict])
async def process_payment(
    payload: ProcessPaymentRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        order_uuid = uuid.UUID(payload.order_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid order_id")

    result = await db.execute(
        select(Order).where(Order.id == order_uuid, Order.user_id == current_user.id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    amount = float(order.total)
    method = payload.payment_method_id.lower()
    return_url = f"{settings.PUBLIC_BACKEND_URL}/api/v1/payments/return?order_id={order.id}"

    if method == "payme":
        merchant_id = settings.payme_active_merchant_id
        if not merchant_id:
            raise HTTPException(status_code=400, detail="Payme is not configured yet")
        amount_tiyin = int(round(amount * 100))
        raw = f"m={merchant_id};ac.order_id={order.id};a={amount_tiyin};c={return_url}"
        encoded = base64.b64encode(raw.encode()).decode()
        # PAYME_TEST_MODE=true bo'lsa sandbox manziliga (test.paycom.uz) ketadi
        url = f"{settings.payme_checkout_base}/{encoded}"
    elif method == "click":
        if not settings.CLICK_SERVICE_ID:
            raise HTTPException(status_code=400, detail="Click is not configured yet")
        url = (
            f"https://my.click.uz/services/pay"
            f"?service_id={settings.CLICK_SERVICE_ID}"
            f"&merchant_id={settings.CLICK_MERCHANT_ID}"
            f"&amount={amount}"
            f"&transaction_param={order.id}"
            f"&return_url={quote(return_url, safe='')}"
        )
    else:
        raise HTTPException(status_code=400, detail="Unsupported payment method")

    return APIResponse(data={"payment_url": url})


# ──────────────────────────────────────────────
# 2b. Real payment status (single source of truth)
# ──────────────────────────────────────────────

@router.get("/status/{order_id}", response_model=APIResponse[dict])
async def payment_status(
    order_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Buyurtma HAQIQATAN to'langanmi. To'lov tizimidan qaytgan URL
    hech qachon to'lov dalili emas — faqat shu endpoint javob beradi."""
    result = await db.execute(
        select(Order).where(Order.id == order_id, Order.user_id == current_user.id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    payment_status_value = (order.payment_status or "pending").lower()
    return APIResponse(data={
        "order_id": str(order.id),
        "payment_status": payment_status_value,
        "order_status": order.status,
        "is_paid": payment_status_value == "paid",
    })


_RETURN_PAGE = """
<!doctype html>
<html lang="uz"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
<title>Milliy Metr</title>
<style>
  body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
         text-align: center; padding: 64px 24px; color: #11181C; }}
  h2 {{ margin-bottom: 8px; }}
  p  {{ color: #536471; }}
  .icon {{ font-size: 48px; margin-bottom: 16px; }}
</style></head>
<body>
  <div class="icon">{icon}</div>
  <h2>{title}</h2>
  <p>{message}</p>
</body></html>
"""


@router.get("/return", response_class=HTMLResponse)
async def payment_return_page(order_id: str = None, db: AsyncSession = Depends(get_db)):
    """To'lov tizimi to'lovdan keyin shu manzilga qaytaradi.

    Bu sahifa haqiqiy holatni bazadan tekshiradi — hech qachon
    "to'landi" deb yolg'on gapirmaydi.
    """
    fallback = HTMLResponse(_RETURN_PAGE.format(
        icon="&#8505;",
        title="Ilovaga qayting",
        message="Buyurtma holatini ilovadan tekshirishingiz mumkin.",
    ))

    if not order_id:
        return fallback

    try:
        oid = uuid.UUID(order_id)
    except ValueError:
        return fallback

    result = await db.execute(select(Order).where(Order.id == oid))
    order = result.scalar_one_or_none()

    if not order:
        return fallback

    status_value = (order.payment_status or "pending").lower()

    if status_value == "paid":
        return HTMLResponse(_RETURN_PAGE.format(
            icon="&#10004;",
            title="To'lov qabul qilindi",
            message="Buyurtmangiz tasdiqlandi. Ilovaga qaytishingiz mumkin.",
        ))
    if status_value in ("cancelled", "refunded"):
        return HTMLResponse(_RETURN_PAGE.format(
            icon="&#10006;",
            title="To'lov amalga oshmadi",
            message="To'lov bekor qilindi. Ilovadan qayta urinib ko'ring.",
        ))

    return HTMLResponse(_RETURN_PAGE.format(
        icon="&#8987;",
        title="To'lov tekshirilmoqda",
        message="To'lov hali tasdiqlanmadi. Ilovaga qaytib, buyurtma holatini kuzating.",
    ))


# ──────────────────────────────────────────────
# 3. Admin: list payments
# ──────────────────────────────────────────────

@router.get("/admin/list", response_model=APIResponse[list])
async def admin_list_payments(
    page: int = 1,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    offset = (page - 1) * limit
    result = await db.execute(
        select(Payment)
        .options(joinedload(Payment.order).joinedload(Order.user))
        .order_by(Payment.created_at.desc())
        .offset(offset)
        .limit(limit)
    )
    payments = result.scalars().all()
    data = []
    for p in payments:
        data.append({
            "id": str(p.id),
            "order_id": str(p.order_id),
            "order_number": p.order.order_number if p.order else None,
            "customer_name": p.order.user.full_name if p.order and p.order.user else None,
            "provider": p.provider,
            "transaction_id": p.transaction_id,
            "amount": p.amount,
            "status": p.status,
            "cancel_reason": p.cancel_reason,
            "raw_payload": p.raw_payload,
            "created_at": p.created_at.isoformat() if p.created_at else None,
            "updated_at": p.updated_at.isoformat() if p.updated_at else None,
            "perform_time": p.perform_time.isoformat() if p.perform_time else None,
            "cancel_time": p.cancel_time.isoformat() if p.cancel_time else None,
        })
    return APIResponse(data=data)


# ══════════════════════════════════════════════
#             PAYME (JSON-RPC 2.0)
# ══════════════════════════════════════════════

PAYME_ERRORS = {
    "PERM_DENIED": -32504,
    "PARSE_ERROR": -32700,
    "INVALID_PARAMS": -32600,
    "METHOD_NOT_FOUND": -32601,
    "SYSTEM_ERROR": -32400,
    "INVALID_AMOUNT": -31001,
    "CANT_PERFORM": -31008,
    "TRANSACTION_NOT_FOUND": -31003,
    "CANT_CANCEL": -31007,
    "ACCOUNT_NOT_FOUND": -31050,
}

PAYME_KEY_SETTING = "payme_key_override"


def _payme_error(id_, code, message_uz, message_ru, message_en):
    return JSONResponse(content={
        "jsonrpc": "2.0", "id": id_,
        "error": {
            "code": code,
            "message": {"uz": message_uz, "ru": message_ru, "en": message_en},
        }
    })


def _payme_result(id_, result):
    return JSONResponse(content={"jsonrpc": "2.0", "id": id_, "result": result})


def _now_ms():
    return int(datetime.utcnow().timestamp() * 1000)


async def _get_stored_payme_key(db) -> str:
    """ChangePassword orqali o'rnatilgan parolni o'qiydi (bo'lmasa bo'sh)."""
    try:
        from app.models.app_settings import AppSetting
        row = (await db.execute(
            select(AppSetting).where(AppSetting.key == PAYME_KEY_SETTING)
        )).scalar_one_or_none()
        return row.value if row and row.value else ""
    except Exception:
        return ""


@router.post("/payme/webhook")
async def payme_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    body = await request.json()
    req_id = body.get("id")
    method = body.get("method")
    params = body.get("params", {})

    auth_header = request.headers.get("Authorization", "")
    provided = auth_header.replace("Basic ", "")

    # Prod kaliti, sandbox kaliti va ChangePassword orqali o'rnatilgan
    # parol — uchalasi ham qabul qilinadi. Shu tufayli sertifikatsiya
    # production sozlamasini buzmaydi.
    stored = await _get_stored_payme_key(db)
    accepted_keys = [k for k in (settings.PAYME_KEY, settings.PAYME_TEST_KEY, stored) if k]
    authorized = any(
        hmac.compare_digest(
            provided,
            base64.b64encode(f"Paycom:{key}".encode()).decode(),
        )
        for key in accepted_keys
    )

    if not authorized:
        return _payme_error(req_id, PAYME_ERRORS["PERM_DENIED"],
                            "Ruxsat yo'q", "Доступ запрещён", "Access denied")

    handlers = {
        "CheckPerformTransaction": _payme_check_perform,
        "CreateTransaction": _payme_create,
        "PerformTransaction": _payme_perform,
        "CancelTransaction": _payme_cancel,
        "CheckTransaction": _payme_check,
        "GetStatement": _payme_get_statement,
        "ChangePassword": _payme_change_password,
    }
    handler = handlers.get(method)
    if not handler:
        return _payme_error(req_id, PAYME_ERRORS["METHOD_NOT_FOUND"],
                            "Metod topilmadi", "Метод не найден", "Method not found")
    return await handler(req_id, params, body, db)


async def _find_order_by_account(params, db):
    account = params.get("account", {})
    order_id_str = account.get("order_id")
    if not order_id_str:
        return None
    try:
        oid = uuid.UUID(order_id_str)
    except ValueError:
        return None
    result = await db.execute(select(Order).where(Order.id == oid))
    return result.scalar_one_or_none()


async def _payme_check_perform(req_id, params, body, db):
    order = await _find_order_by_account(params, db)
    if not order:
        return _payme_error(req_id, PAYME_ERRORS["ACCOUNT_NOT_FOUND"],
                            "Buyurtma topilmadi", "Заказ не найден", "Order not found")

    expected_amount = int(round(float(order.total) * 100))
    if params.get("amount") != expected_amount:
        return _payme_error(req_id, PAYME_ERRORS["INVALID_AMOUNT"],
                            "Noto'g'ri summa", "Неверная сумма", "Invalid amount")

    existing = await db.execute(
        select(Payment).where(Payment.order_id == order.id, Payment.status == "performed")
    )
    if existing.scalar_one_or_none():
        return _payme_error(req_id, PAYME_ERRORS["CANT_PERFORM"],
                            "Allaqachon to'langan", "Уже оплачено", "Already paid")

    return _payme_result(req_id, {"allow": True})


async def _payme_create(req_id, params, body, db):
    payme_id = params.get("id")

    existing = await db.execute(
        select(Payment).where(Payment.transaction_id == payme_id)
    )
    payment = existing.scalar_one_or_none()
    if payment:
        if payment.status == "cancelled":
            return _payme_error(req_id, PAYME_ERRORS["CANT_PERFORM"],
                                "Tranzaksiya bekor qilingan", "Транзакция отменена", "Transaction cancelled")
        return _payme_result(req_id, {
            "create_time": int(payment.created_at.timestamp() * 1000),
            "transaction": str(payment.id),
            "state": 1,
        })

    order = await _find_order_by_account(params, db)
    if not order:
        return _payme_error(req_id, PAYME_ERRORS["ACCOUNT_NOT_FOUND"],
                            "Buyurtma topilmadi", "Заказ не найден", "Order not found")

    expected_amount = int(round(float(order.total) * 100))
    if params.get("amount") != expected_amount:
        return _payme_error(req_id, PAYME_ERRORS["INVALID_AMOUNT"],
                            "Noto'g'ri summa", "Неверная сумма", "Invalid amount")

    payment = Payment(
        order_id=order.id,
        provider="payme",
        transaction_id=payme_id,
        amount=params.get("amount"),
        status="created",
        raw_payload=body,
    )
    db.add(payment)
    order.payment_status = "Waiting"
    await db.commit()
    await db.refresh(payment)

    return _payme_result(req_id, {
        "create_time": int(payment.created_at.timestamp() * 1000),
        "transaction": str(payment.id),
        "state": 1,
    })


async def _payme_perform(req_id, params, body, db):
    payme_id = params.get("id")
    existing = await db.execute(
        select(Payment).options(joinedload(Payment.order)).where(Payment.transaction_id == payme_id)
    )
    payment = existing.scalar_one_or_none()
    if not payment:
        return _payme_error(req_id, PAYME_ERRORS["TRANSACTION_NOT_FOUND"],
                            "Tranzaksiya topilmadi", "Транзакция не найдена", "Transaction not found")

    if payment.status == "performed":
        return _payme_result(req_id, {
            "transaction": str(payment.id),
            "perform_time": int(payment.perform_time.timestamp() * 1000) if payment.perform_time else _now_ms(),
            "state": 2,
        })

    if payment.status != "created":
        return _payme_error(req_id, PAYME_ERRORS["CANT_PERFORM"],
                            "Amalga oshirib bo'lmaydi", "Невозможно выполнить", "Cannot perform")

    now = datetime.utcnow()
    payment.status = "performed"
    payment.perform_time = now
    payment.raw_payload = body
    payment.order.payment_status = "Paid"
    payment.order.status = "Confirmed"
    await db.commit()

    return _payme_result(req_id, {
        "transaction": str(payment.id),
        "perform_time": int(now.timestamp() * 1000),
        "state": 2,
    })


async def _payme_cancel(req_id, params, body, db):
    payme_id = params.get("id")
    reason = params.get("reason")

    existing = await db.execute(
        select(Payment)
        .options(joinedload(Payment.order).joinedload(Order.items))
        .where(Payment.transaction_id == payme_id)
    )
    payment = existing.unique().scalar_one_or_none()
    if not payment:
        return _payme_error(req_id, PAYME_ERRORS["TRANSACTION_NOT_FOUND"],
                            "Tranzaksiya topilmadi", "Транзакция не найдена", "Transaction not found")

    if payment.status in ("cancelled", "cancelled_after_perform"):
        state = -1 if payment.status == "cancelled" else -2
        return _payme_result(req_id, {
            "transaction": str(payment.id),
            "cancel_time": int(payment.cancel_time.timestamp() * 1000) if payment.cancel_time else _now_ms(),
            "state": state,
        })

    now = datetime.utcnow()
    order = payment.order

    if payment.status == "created":
        payment.status = "cancelled"
        payment.cancel_reason = reason
        payment.cancel_time = now
        payment.raw_payload = body
        order.payment_status = "Cancelled"
        state = -1

    elif payment.status == "performed":
        if order.delivery_status and order.delivery_status.lower() == "delivered":
            return _payme_error(req_id, PAYME_ERRORS["CANT_CANCEL"],
                                "Bekor qilib bo'lmaydi", "Невозможно отменить", "Cannot cancel after delivery")

        payment.status = "cancelled_after_perform"
        payment.cancel_reason = reason
        payment.cancel_time = now
        payment.raw_payload = body
        order.payment_status = "Refunded"
        order.status = "Cancelled"
        state = -2

        for item in order.items:
            await db.execute(
                update(Product).where(Product.id == item.product_id)
                .values(stock=Product.stock + item.quantity)
            )
    else:
        return _payme_error(req_id, PAYME_ERRORS["CANT_CANCEL"],
                            "Bekor qilib bo'lmaydi", "Невозможно отменить", "Cannot cancel")

    await db.commit()

    return _payme_result(req_id, {
        "transaction": str(payment.id),
        "cancel_time": int(now.timestamp() * 1000),
        "state": state,
    })


async def _payme_check(req_id, params, body, db):
    payme_id = params.get("id")
    existing = await db.execute(
        select(Payment).where(Payment.transaction_id == payme_id)
    )
    payment = existing.scalar_one_or_none()
    if not payment:
        return _payme_error(req_id, PAYME_ERRORS["TRANSACTION_NOT_FOUND"],
                            "Tranzaksiya topilmadi", "Транзакция не найдена", "Transaction not found")

    state_map = {
        "pending": 1, "created": 1, "performed": 2,
        "cancelled": -1, "cancelled_after_perform": -2,
    }
    state = state_map.get(payment.status, 1)

    result = {
        "create_time": int(payment.created_at.timestamp() * 1000),
        "perform_time": int(payment.perform_time.timestamp() * 1000) if payment.perform_time else 0,
        "cancel_time": int(payment.cancel_time.timestamp() * 1000) if payment.cancel_time else 0,
        "transaction": str(payment.id),
        "state": state,
        "reason": payment.cancel_reason,
    }
    return _payme_result(req_id, result)


async def _payme_get_statement(req_id, params, body, db):
    """Davr ichidagi tranzaksiyalar ro'yxati (Payme solishtirish uchun so'raydi)."""
    frm = params.get("from")
    to = params.get("to")

    if frm is None or to is None:
        return _payme_error(req_id, PAYME_ERRORS["INVALID_PARAMS"],
                            "Parametrlar noto'g'ri", "Неверные параметры", "Invalid params")

    start = datetime.utcfromtimestamp(frm / 1000)
    end = datetime.utcfromtimestamp(to / 1000)

    rows = (await db.execute(
        select(Payment)
        .options(joinedload(Payment.order))
        .where(
            Payment.provider == "payme",
            Payment.created_at >= start,
            Payment.created_at <= end,
        )
        .order_by(Payment.created_at.asc())
    )).unique().scalars().all()

    state_map = {
        "pending": 1, "created": 1, "performed": 2,
        "cancelled": -1, "cancelled_after_perform": -2,
    }

    transactions = []
    for p in rows:
        transactions.append({
            "id": p.transaction_id,
            "time": int(p.created_at.timestamp() * 1000) if p.created_at else 0,
            "amount": int(p.amount or 0),
            "account": {"order_id": str(p.order_id)},
            "create_time": int(p.created_at.timestamp() * 1000) if p.created_at else 0,
            "perform_time": int(p.perform_time.timestamp() * 1000) if p.perform_time else 0,
            "cancel_time": int(p.cancel_time.timestamp() * 1000) if p.cancel_time else 0,
            "transaction": str(p.id),
            "state": state_map.get(p.status, 1),
            "reason": p.cancel_reason,
            "receivers": None,
        })

    return _payme_result(req_id, {"transactions": transactions})


async def _payme_change_password(req_id, params, body, db):
    """Kassa parolini o'zgartiradi. Yangi parol bazada saqlanadi va
    webhook autentifikatsiyasida qabul qilinadi."""
    new_password = params.get("password")

    if not new_password or not isinstance(new_password, str) or len(new_password.strip()) < 8:
        return _payme_error(req_id, PAYME_ERRORS["INVALID_PARAMS"],
                            "Parol noto'g'ri", "Неверный пароль", "Invalid password")

    from app.models.app_settings import AppSetting

    row = (await db.execute(
        select(AppSetting).where(AppSetting.key == PAYME_KEY_SETTING)
    )).scalar_one_or_none()

    if row:
        row.value = new_password
    else:
        db.add(AppSetting(key=PAYME_KEY_SETTING, value=new_password))

    await db.commit()
    return _payme_result(req_id, {"success": True})


# ══════════════════════════════════════════════
#        CLICK (SHOP-API, Prepare/Complete)
# ══════════════════════════════════════════════

def _click_verify_sign(data: dict, action: str) -> bool:
    parts = [
        str(data.get("click_trans_id", "")),
        str(data.get("service_id", "")),
        settings.CLICK_SECRET_KEY,
        str(data.get("merchant_trans_id", "")),
    ]
    if action == "1":
        parts.append(str(data.get("merchant_prepare_id", "")))
    parts += [
        str(data.get("amount", "")),
        str(data.get("action", "")),
        str(data.get("sign_time", "")),
    ]
    expected = hashlib.md5("".join(parts).encode()).hexdigest()
    return hmac.compare_digest(expected, str(data.get("sign_string", "")))


def _click_response(data, error, error_note, extra=None):
    resp = {
        "click_trans_id": data.get("click_trans_id"),
        "merchant_trans_id": data.get("merchant_trans_id"),
        "error": error,
        "error_note": error_note,
    }
    if extra:
        resp.update(extra)
    return resp


@router.post("/click/webhook")
async def click_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    form = await request.form()
    data = dict(form)
    action = str(data.get("action", ""))

    if not _click_verify_sign(data, action):
        return _click_response(data, -1, "SIGN CHECK FAILED")

    if action == "0":
        return await _click_prepare(data, db)
    elif action == "1":
        return await _click_complete(data, db)
    else:
        return _click_response(data, -3, "Action not found")


async def _click_prepare(data, db):
    merchant_trans_id = data.get("merchant_trans_id", "")
    click_trans_id = str(data.get("click_trans_id", ""))
    amount = float(data.get("amount", 0))

    try:
        order_uuid = uuid.UUID(merchant_trans_id)
    except ValueError:
        return _click_response(data, -5, "Order not found")

    result = await db.execute(select(Order).where(Order.id == order_uuid))
    order = result.scalar_one_or_none()
    if not order:
        return _click_response(data, -5, "Order not found")

    if abs(float(order.total) - amount) > 0.01:
        return _click_response(data, -2, "Incorrect amount")

    existing = await db.execute(
        select(Payment).where(Payment.transaction_id == click_trans_id)
    )
    payment = existing.scalar_one_or_none()
    if payment:
        if payment.status == "cancelled":
            return _click_response(data, -9, "Transaction cancelled")
        return _click_response(data, 0, "Success", {
            "merchant_prepare_id": str(payment.id),
        })

    paid_check = await db.execute(
        select(Payment).where(Payment.order_id == order.id, Payment.status == "performed")
    )
    if paid_check.scalar_one_or_none():
        return _click_response(data, -4, "Already paid")

    payment = Payment(
        order_id=order.id,
        provider="click",
        transaction_id=click_trans_id,
        amount=int(round(amount * 100)),  # store in tiyin for consistency
        status="created",
        raw_payload=data,
    )
    db.add(payment)
    order.payment_status = "Waiting"
    await db.commit()
    await db.refresh(payment)

    return _click_response(data, 0, "Success", {
        "merchant_prepare_id": str(payment.id),
    })


async def _click_complete(data, db):
    click_trans_id = str(data.get("click_trans_id", ""))
    click_error = int(data.get("error", 0))

    existing = await db.execute(
        select(Payment)
        .options(joinedload(Payment.order).joinedload(Order.items))
        .where(Payment.transaction_id == click_trans_id)
    )
    payment = existing.unique().scalar_one_or_none()
    if not payment:
        return _click_response(data, -6, "Transaction not found")

    if payment.status == "performed":
        return _click_response(data, 0, "Success", {
            "merchant_trans_id": str(payment.order_id),
            "merchant_prepare_id": str(payment.id),
        })

    if payment.status == "cancelled":
        return _click_response(data, -9, "Transaction cancelled")

    order = payment.order

    if click_error < 0:
        payment.status = "cancelled"
        payment.cancel_time = datetime.utcnow()
        payment.raw_payload = data
        order.payment_status = "Cancelled"
        await db.commit()
        return _click_response(data, click_error, "Payment failed", {
            "merchant_trans_id": str(payment.order_id),
            "merchant_prepare_id": str(payment.id),
        })

    now = datetime.utcnow()
    payment.status = "performed"
    payment.perform_time = now
    payment.raw_payload = data
    order.payment_status = "Paid"
    order.status = "Confirmed"
    await db.commit()

    return _click_response(data, 0, "Success", {
        "merchant_trans_id": str(payment.order_id),
        "merchant_prepare_id": str(payment.id),
    })
