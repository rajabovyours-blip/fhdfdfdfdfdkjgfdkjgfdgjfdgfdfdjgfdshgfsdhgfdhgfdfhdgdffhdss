from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import uuid
import io
from PIL import Image

try:
    from rembg import remove
except ImportError:
    remove = None

router = APIRouter()

# Ensure uploads directory exists. Use absolute path for Render persistent disk
BASE_UPLOAD_DIR = os.getenv("UPLOAD_DIR", "/app/uploads")
UPLOAD_DIR = os.path.join(BASE_UPLOAD_DIR, "images")
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Path to the watermark logo
WATERMARK_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))), "assets", "watermark.png")

def process_image(image_bytes, watermark_path):
    # Remove background if rembg is available
    if remove:
        output_bytes = remove(image_bytes)
        base_image = Image.open(io.BytesIO(output_bytes))
    else:
        base_image = Image.open(io.BytesIO(image_bytes))
        
    base_image = base_image.convert("RGBA")
    
    # Add watermark
    if os.path.exists(watermark_path):
        try:
            with Image.open(watermark_path) as watermark:
                watermark = watermark.convert("RGBA")
                
                # Resize watermark to be 15% of the image width
                wm_width = int(base_image.width * 0.15)
                wm_ratio = wm_width / float(watermark.width)
                wm_height = int(watermark.height * wm_ratio)
                watermark = watermark.resize((wm_width, wm_height), Image.Resampling.LANCZOS)
                
                # Adjust opacity to 50%
                alpha = watermark.split()[3]
                alpha = alpha.point(lambda p: p * 0.5)
                watermark.putalpha(alpha)
                
                # Create transparent layer and paste watermark at top corner (10, 10)
                transparent = Image.new('RGBA', base_image.size, (0,0,0,0))
                transparent.paste(watermark, (10, 10), mask=watermark)
                
                # Composite
                base_image = Image.alpha_composite(base_image, transparent)
        except Exception as e:
            print(f"Failed to add watermark: {e}")
            
    return base_image

@router.post("/image")
async def upload_image(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image")
    
    unique_filename = f"{uuid.uuid4().hex}.png"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    from starlette.concurrency import run_in_threadpool
    
    try:
        content = await file.read()
        final_image = await run_in_threadpool(process_image, content, WATERMARK_PATH)
        await run_in_threadpool(final_image.save, file_path, "PNG")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {e}")
        
    return {
        "data": {
            "url": f"/uploads/images/{unique_filename}",
            "filename": unique_filename
        }
    }
