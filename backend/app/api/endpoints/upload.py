from fastapi import APIRouter, UploadFile, File, HTTPException, Query
import os
import uuid
import io
from PIL import Image

router = APIRouter()

# Ensure uploads directory exists. Use absolute path for Render persistent disk
BASE_UPLOAD_DIR = os.getenv("UPLOAD_DIR", "/app/uploads")
UPLOAD_DIR = os.path.join(BASE_UPLOAD_DIR, "images")
VIDEO_UPLOAD_DIR = os.path.join(BASE_UPLOAD_DIR, "videos")
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(VIDEO_UPLOAD_DIR, exist_ok=True)

# Video banner cheklovlari. Bular server tomonda hech qanday siqish
# (transcode) qilmaydi — faqat "aqlga to'g'ri keladigan" hajmda ekanini
# tekshiradi. Admin panelda ham aynan shu raqamlar ko'rsatiladi, shunda
# admin videoni yuklashdan oldin biladi.
MAX_VIDEO_BYTES = 20 * 1024 * 1024  # 20 MB
ALLOWED_VIDEO_TYPES = {"video/mp4", "video/quicktime", "video/x-m4v"}

# Animatsiyali GIF hajmi ham cheklanadi — GIF formati o'zi samarasiz
# (video kabi siqilmaydi), shuning uchun bir necha soniyalik banner
# ham osongina 20-30 MB bo'lib qolishi mumkin.
MAX_GIF_BYTES = 15 * 1024 * 1024  # 15 MB

# Path to the watermark logo
WATERMARK_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))), "assets", "watermark.png")


def process_image(image_bytes, watermark_path, add_watermark: bool):
    """Rasmni ochadi va FAQAT so'ralganda logotip qo'yadi.

    MUHIM: logotip faqat MAHSULOT rasmlariga qo'yiladi. Kategoriya,
    banner, bildirishnoma va foydalanuvchi avatariga qo'yilmasligi kerak —
    aks holda ilovaning hamma joyida logotip takrorlanib chiqadi.
    """
    base_image = Image.open(io.BytesIO(image_bytes))
    base_image = base_image.convert("RGBA")

    if not add_watermark:
        return base_image

    if os.path.exists(watermark_path):
        try:
            with Image.open(watermark_path) as watermark:
                watermark = watermark.convert("RGBA")

                # Resize watermark to be 25% of the image width
                wm_width = int(base_image.width * 0.25)
                wm_ratio = wm_width / float(watermark.width)
                wm_height = int(watermark.height * wm_ratio)
                watermark = watermark.resize((wm_width, wm_height), Image.Resampling.LANCZOS)

                # Yurakcha (sevimlilar) tugmasi ilovada yuqori O'NG burchakda
                # turadi — shuning uchun logotip u bilan to'qnashmasligi uchun
                # yuqori CHAP burchakka joylashtiriladi.
                padding_x = 20
                padding_y = 20
                pos_x = padding_x
                pos_y = padding_y

                # Create transparent layer and paste watermark
                transparent = Image.new('RGBA', base_image.size, (0, 0, 0, 0))
                transparent.paste(watermark, (pos_x, pos_y), mask=watermark)

                # Composite
                base_image = Image.alpha_composite(base_image, transparent)
        except Exception as e:
            print(f"Failed to add watermark: {e}")

    return base_image


def _looks_like_gif(content: bytes, content_type: str) -> bool:
    """GIF ekanini ikki usulda tekshiradi: brauzer bergan MIME turi va
    faylning o'zidagi "sehrli baytlar" (magic bytes). Ikkinchisi
    ishonchliroq — ba'zi brauzer/qurilmalar noto'g'ri MIME yuborishi
    mumkin, lekin fayl boshidagi "GIF87a"/"GIF89a" imzosi hech qachon
    yolg'on bo'lmaydi.
    """
    if content_type == "image/gif":
        return True
    return content[:6] in (b"GIF87a", b"GIF89a")


@router.post("/image")
async def upload_image(
    file: UploadFile = File(...),
    watermark: bool = Query(
        False,
        description="Logotip qo'yilsinmi. FAQAT mahsulot rasmlari uchun true.",
    ),
):
    """Rasm yuklash.

    `watermark=true` bo'lgandagina Milliy Metr logotipi qo'yiladi.
    Standart qiymat — false, ya'ni kategoriya/banner/avatar rasmlari
    toza, logotipsiz saqlanadi.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image")

    from starlette.concurrency import run_in_threadpool

    content = await file.read()

    # MUHIM: animatsiyali GIF alohida yo'l bilan boradi. Agar bu yerda
    # oddiy rasm kabi PIL orqali ochib PNG'ga saqlansa (pastdagi asosiy
    # yo'l), PNG bitta kadrni saqlaydi — animatsiya BUTUNLAY yo'qoladi.
    # Shuning uchun GIF UMUMAN qayta ishlanmaydi (watermark ham qo'yilmaydi,
    # chunki kadr-kadr watermark qo'yish alohida, katta ish talab qiladi va
    # bannerlar hozircha logotip so'ramaydi) — asl baytlar aynan qanday
    # kelgan bo'lsa, shundayligicha saqlanadi.
    if _looks_like_gif(content, file.content_type):
        if len(content) > MAX_GIF_BYTES:
            size_mb = round(len(content) / (1024 * 1024), 1)
            raise HTTPException(
                status_code=400,
                detail=f"GIF hajmi {size_mb} MB — ruxsat etilgan maksimal hajm 15 MB. "
                       f"Kadrlar sonini yoki o'lchamini kamaytirib qayta yuklang.",
            )
        unique_filename = f"{uuid.uuid4().hex}.gif"
        file_path = os.path.join(UPLOAD_DIR, unique_filename)
        try:
            with open(file_path, "wb") as f:
                f.write(content)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to upload gif: {e}")
        return {
            "data": {
                "url": f"/uploads/images/{unique_filename}",
                "filename": unique_filename,
                "watermarked": False,
                "animated": True,
            }
        }

    unique_filename = f"{uuid.uuid4().hex}.png"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)

    try:
        final_image = await run_in_threadpool(
            process_image, content, WATERMARK_PATH, watermark
        )
        # PNG - lossless (sifat yo'qotilmaydi). Asosiy sifat pasayishi
        # oldin admin panelning client-side siqishida bo'lgan (image-utils.js) —
        # u alohida tuzatildi.
        await run_in_threadpool(final_image.save, file_path, "PNG", optimize=True)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {e}")

    return {
        "data": {
            "url": f"/uploads/images/{unique_filename}",
            "filename": unique_filename,
            "watermarked": watermark,
        }
    }


@router.post("/video")
async def upload_video(file: UploadFile = File(...)):
    """Banner uchun video yuklash.

    Faqat MP4 (H.264) qabul qilinadi va serverda HECH QANDAY qayta ishlov
    (transcode/siqish) qilinmaydi — fayl aynan qanday yuklangan bo'lsa,
    shunday saqlanadi. Shuning uchun admin videoni oldindan to'g'ri
    o'lchamda va sifatda tayyorlab yuklashi kerak (admin panelda
    ko'rsatilgan tavsiyalarga qarang).

    Hajm 20 MB bilan cheklangan — bundan katta video ilovada sekin
    yuklanadi va mijozning internet trafigini isrof qiladi.
    """
    content_type = (file.content_type or "").lower()
    if content_type not in ALLOWED_VIDEO_TYPES and not content_type.startswith("video/"):
        raise HTTPException(status_code=400, detail="Fayl video formatida emas")

    content = await file.read()
    if len(content) > MAX_VIDEO_BYTES:
        size_mb = round(len(content) / (1024 * 1024), 1)
        raise HTTPException(
            status_code=400,
            detail=f"Video hajmi {size_mb} MB — ruxsat etilgan maksimal hajm 20 MB. "
                   f"Videoni siqib (masalan HandBrake yoki CapCut orqali) qayta yuklang.",
        )
    if len(content) == 0:
        raise HTTPException(status_code=400, detail="Fayl bo'sh")

    unique_filename = f"{uuid.uuid4().hex}.mp4"
    file_path = os.path.join(VIDEO_UPLOAD_DIR, unique_filename)

    try:
        with open(file_path, "wb") as f:
            f.write(content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload video: {e}")

    return {
        "data": {
            "url": f"/uploads/videos/{unique_filename}",
            "filename": unique_filename,
            "size_bytes": len(content),
        }
    }
