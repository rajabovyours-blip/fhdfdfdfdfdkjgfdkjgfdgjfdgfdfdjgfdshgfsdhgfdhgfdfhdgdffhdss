import os
import cloudinary
import cloudinary.uploader
from fastapi import APIRouter, UploadFile, File, HTTPException

router = APIRouter()

cloudinary.config(
    cloud_name=os.environ.get("CLOUDINARY_CLOUD_NAME"),
    api_key=os.environ.get("CLOUDINARY_API_KEY"),
    api_secret=os.environ.get("CLOUDINARY_API_SECRET"),
    secure=True,
)

@router.post("/image")
async def upload_image(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image")

    try:
        result = cloudinary.uploader.upload(
            file.file,
            folder="milliy_metr",
            resource_type="image",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {e}")

    return {
        "data": {
            "url": result["secure_url"],
            "filename": result["public_id"],
        }
    }
