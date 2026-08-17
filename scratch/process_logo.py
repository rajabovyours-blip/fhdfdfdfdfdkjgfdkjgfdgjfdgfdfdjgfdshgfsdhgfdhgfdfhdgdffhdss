import sys
import os
from rembg import remove
from PIL import Image

input_path = "C:/Users/rajab/.gemini/antigravity-ide/brain/11ff58b3-d3ba-4f53-aa3e-4a978aa4044b/.user_uploaded/media_1786940198553.jpg"
output_path = "assets/images/logo_transparent.png"

# Create output dir if needed
os.makedirs(os.path.dirname(output_path), exist_ok=True)

print("Loading image...")
input_image = Image.open(input_path)

print("Removing background...")
output_image = remove(input_image)

print(f"Saving to {output_path}...")
output_image.save(output_path, format="PNG")
print("Done!")
