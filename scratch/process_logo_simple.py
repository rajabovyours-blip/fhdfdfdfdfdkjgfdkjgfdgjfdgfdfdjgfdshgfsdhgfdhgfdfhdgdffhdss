import sys
import os
from PIL import Image

input_path = "C:/Users/rajab/.gemini/antigravity-ide/brain/11ff58b3-d3ba-4f53-aa3e-4a978aa4044b/.user_uploaded/media_1786940198553.jpg"
output_path = "assets/images/logo_transparent.png"

os.makedirs(os.path.dirname(output_path), exist_ok=True)

img = Image.open(input_path).convert("RGBA")
datas = img.getdata()

bg_color = datas[0] # Top-left pixel color
tolerance = 45 # Simple tolerance for jpeg artifacts

new_data = []
for item in datas:
    if abs(item[0]-bg_color[0]) < tolerance and abs(item[1]-bg_color[1]) < tolerance and abs(item[2]-bg_color[2]) < tolerance:
        new_data.append((255, 255, 255, 0)) # transparent
    else:
        new_data.append(item)

img.putdata(new_data)
img.save(output_path, "PNG")
print("Saved transparent logo to", output_path)
