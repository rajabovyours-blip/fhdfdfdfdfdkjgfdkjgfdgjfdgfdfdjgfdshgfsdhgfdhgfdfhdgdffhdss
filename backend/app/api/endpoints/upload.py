from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import uuid
from PIL import Image

router = APIRouter()

# Ensure uploads directory exists. Use absolute path for Render persistent disk
BASE_UPLOAD_DIR = os.getenv("UPLOAD_DIR", "/app/uploads")
UPLOAD_DIR = os.path.join(BASE_UPLOAD_DIR, "images")
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Path to the watermark logo
WATERMARK_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "assets", "watermark.png")

def add_watermark(image_path, watermark_path):
    if not os.path.exists(watermark_path):
        return # Silently skip if watermark doesn't exist
        
    try:
        with Image.open(image_path) as base_image:
            with Image.open(watermark_path) as watermark:
                # Convert both to RGBA
                base_image = base_image.convert("RGBA")
                watermark = watermark.convert("RGBA")
                
                # Resize watermark to be proportional to the image (e.g., 20% of width)
                wm_width = int(base_image.width * 0.2)
                wm_ratio = wm_width / watermark.width
                wm_height = int(watermark.height * wm_ratio)
                watermark = watermark.resize((wm_width, wm_height), Image.Resampling.LANCZOS)
                
                # Adjust opacity (optional, making it semi-transparent)
                alpha = watermark.split()[3]
                alpha = alpha.point(lambda p: p * 0.5) # 50% opacity
                watermark.putalpha(alpha)
                
                # Create a transparent layer the size of the base image
                transparent = Image.new('RGBA', base_image.size, (0,0,0,0))
                
                # Paste watermark in the center
                position = (
                    (base_image.width - wm_width) // 2,
                    (base_image.height - wm_height) // 2
                )
                transparent.paste(watermark, position, mask=watermark)
                
                # Composite the images
                watermarked = Image.alpha_composite(base_image, transparent)
                
                # Save as JPEG (requires converting back to RGB)
                final_image = watermarked.convert("RGB")
                
                # Overwrite original
                final_image.save(image_path, "JPEG", quality=85)
    except Exception as e:
        print(f"Failed to add watermark: {e}")
        pass # If watermarking fails, just use the original image

@router.post("/image")
async def upload_image(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image")
    
    # Generate unique filename, always saving as jpg after processing
    unique_filename = f"{uuid.uuid4().hex}.jpg"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    try:
        # First save the raw uploaded file
        content = await file.read()
        with open(file_path, "wb") as buffer:
            buffer.write(content)
            
        # Then apply watermark
        add_watermark(file_path, WATERMARK_PATH)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {e}")
        
    return {
        "data": {
            "url": f"/uploads/images/{unique_filename}",
            "filename": unique_filename
        }
    }
