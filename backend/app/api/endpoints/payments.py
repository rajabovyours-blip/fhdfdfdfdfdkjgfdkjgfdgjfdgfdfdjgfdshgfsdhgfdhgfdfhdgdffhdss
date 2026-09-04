import hashlib
import hmac
import base64
import uuid
import json
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import joinedload
from pydantic import BaseModel as PydanticBaseModel

from app.db.session import get_db
from app.schemas.common import APIResponse
from app.models.order import Order, OrderItem
from app.models.product import Product
from app.models.extras import Payment
from app.models.user import User
from app.core.config import settings
from app.api.deps import get_current_user, get_current_admin

router = APIRouter()


# ──────────────────────────────────────────────
# 1. Payment Methods (existing)
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

    if method == "payme":
        if not settings.PAYME_MERCHANT_ID:
            raise HTTPException(status_code=400, detail="Payme is not configured yet")
        amount_tiyin = int(round(amount * 100))
        raw = f"m={settings.PAYME_MERCHANT_ID};ac.order_id={order.id};a={amount_tiyin}"
        encoded = base64.b64encode(raw.encode()).decode()
        url = f"https://checkout.paycom.uz/{encoded}"
    elif method == "click":
        if not settings.CLICK_SERVICE_ID:
            raise HTTPException(status_code=400, detail="Click is not configured yet")
        url = (
            f"https://my.click.uz/services/pay"
            f"?service_id={settings.CLICK_SERVICE_ID}"
            f"&merchant_id={settings.CLICK_MERCHANT_ID}"
            f"&amount={amount}"
            f"&transaction_param={order.id}"
        )
    else:
        raise HTTPException(status_code=400, detail="Unsupported payment method")

    return APIResponse(data={"payment_url": url})


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


@router.post("/payme/webhook")
async def payme_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    body = await request.json()
    req_id = body.get("id")
    method = body.get("method")
    params = body.get("params", {})

    # 1. Auth check
    auth_header = request.headers.get("Authorization", "")
    expected = base64.b64encode(f"Paycom:{settings.PAYME_KEY}".encode()).decode()
    provided = auth_header.replace("Basic ", "")
    if not hmac.compare_digest(provided, expected):
        return _payme_error(req_id, PAYME_ERRORS["PERM_DENIED"],
                            "Ruxsat yo'q", "Доступ запрещён", "Access denied")

    handlers = {
        "CheckPerformTransaction": _payme_check_perform,
        "CreateTransaction": _payme_create,
        "PerformTransaction": _payme_perform,
        "CancelTransaction": _payme_cancel,
        "CheckTransaction": _payme_check,
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

    # Check if already paid
    existing = await db.execute(
        select(Payment).where(Payment.order_id == order.id, Payment.status == "performed")
    )
    if existing.scalar_one_or_none():
        return _payme_error(req_id, PAYME_ERRORS["CANT_PERFORM"],
                            "Allaqachon to'langan", "Уже оплачено", "Already paid")

    return _payme_result(req_id, {"allow": True})


async def _payme_create(req_id, params, body, db):
    payme_id = params.get("id")

    # Idempotency: check if transaction already exists
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

    # Validate order
    order = await _find_order_by_account(params, db)
    if not order:
        return _payme_error(req_id, PAYME_ERRORS["ACCOUNT_NOT_FOUND"],
                            "Buyurtma topilmadi", "Заказ не найден", "Order not found")

    expected_amount = int(round(float(order.total) * 100))
    if params.get("amount") != expected_amount:
        return _payme_error(req_id, PAYME_ERRORS["INVALID_AMOUNT"],
                            "Noto'g'ri summa", "Неверная сумма", "Invalid amount")

    # Create payment record
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

    # Idempotency
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
    payment = existing.scalar_one_or_none()
    if not payment:
        return _payme_error(req_id, PAYME_ERRORS["TRANSACTION_NOT_FOUND"],
                            "Tranzaksiya topilmadi", "Транзакция не найдена", "Transaction not found")

    # Already cancelled — idempotency
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
        # Money was not yet charged
        payment.status = "cancelled"
        payment.cancel_reason = reason
        payment.cancel_time = now
        payment.raw_payload = body
        order.payment_status = "Cancelled"
        state = -1

    elif payment.status == "performed":
        # Check if already delivered
        if order.delivery_status and order.delivery_status.lower() == "delivered":
            return _payme_error(req_id, PAYME_ERRORS["CANT_CANCEL"],
                                "Bekor qilib bo'lmaydi", "Невозможно отменить", "Cannot cancel after delivery")

        # Money was charged — reversal
        payment.status = "cancelled_after_perform"
        payment.cancel_reason = reason
        payment.cancel_time = now
        payment.raw_payload = body
        order.payment_status = "Refunded"
        order.status = "Cancelled"
        state = -2

        # Restore stock
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

    # Find order
    try:
        order_uuid = uuid.UUID(merchant_trans_id)
    except ValueError:
        return _click_response(data, -5, "Order not found")

    result = await db.execute(select(Order).where(Order.id == order_uuid))
    order = result.scalar_one_or_none()
    if not order:
        return _click_response(data, -5, "Order not found")

    # Check amount (Click sends in so'm)
    if abs(float(order.total) - amount) > 0.01:
        return _click_response(data, -2, "Incorrect amount")

    # Idempotency: check if this click_trans_id already exists
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

    # Check if already paid by another transaction
    paid_check = await db.execute(
        select(Payment).where(Payment.order_id == order.id, Payment.status == "performed")
    )
    if paid_check.scalar_one_or_none():
        return _click_response(data, -4, "Already paid")

    # Create payment
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
    payment = existing.scalar_one_or_none()
    if not payment:
        return _click_response(data, -6, "Transaction not found")

    # Idempotency
    if payment.status == "performed":
        return _click_response(data, 0, "Success", {
            "merchant_trans_id": str(payment.order_id),
            "merchant_prepare_id": str(payment.id),
        })

    if payment.status == "cancelled":
        return _click_response(data, -9, "Transaction cancelled")

    order = payment.order

    if click_error < 0:
        # Click reports error — cancel payment
        payment.status = "cancelled"
        payment.cancel_time = datetime.utcnow()
        payment.raw_payload = data
        order.payment_status = "Cancelled"
        await db.commit()
        return _click_response(data, click_error, "Payment failed", {
            "merchant_trans_id": str(payment.order_id),
            "merchant_prepare_id": str(payment.id),
        })

    # Success
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
