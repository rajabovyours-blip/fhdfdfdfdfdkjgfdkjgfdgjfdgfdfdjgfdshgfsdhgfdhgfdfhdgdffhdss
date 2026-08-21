from PIL import Image
import sys

img_path = 'C:/Users/rajab/OneDrive/Desktop/MilliyMetr/assets/images/categories/cat-1.webp'
try:
    img = Image.open(img_path)
    print(f'Format: {img.format}, Mode: {img.mode}, Size: {img.size}')
    
    if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
        print('Image has transparency.')
        # Check if the transparent pixels are the background
        alpha = img.split()[-1]
        transparent_pixels = sum(1 for p in alpha.getdata() if p == 0)
        print(f'Transparent pixels: {transparent_pixels}')
    else:
        print('Image does not have transparency.')
except Exception as e:
    print(f'Error: {e}')
