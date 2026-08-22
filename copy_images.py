import os
import glob
from PIL import Image

artifact_dir = r"C:\Users\rajab\.gemini\antigravity-ide\brain\17588462-6b6d-424b-b8f2-9794b9d00b62"
target_dir = r"c:\Users\rajab\OneDrive\Desktop\MilliyMetr\assets\images\categories"

# Generate list of generated files (e.g. cat_1_12345.jpg)
generated_files = glob.glob(os.path.join(artifact_dir, "cat_*_*.jpg"))

print(f"Found {len(generated_files)} generated images.")

for file_path in generated_files:
    # Extract cat_X
    filename = os.path.basename(file_path)
    parts = filename.split('_')
    cat_num = parts[1]
    
    target_filename = f"cat-{cat_num}.webp"
    target_path = os.path.join(target_dir, target_filename)
    
    # Open and convert
    img = Image.open(file_path)
    img.save(target_path, "webp")
    print(f"Converted {filename} -> {target_filename}")

print("Done.")
