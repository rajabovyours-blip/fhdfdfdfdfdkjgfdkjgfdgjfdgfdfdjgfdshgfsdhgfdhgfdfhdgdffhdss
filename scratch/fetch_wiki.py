import requests
from PIL import Image, ImageDraw
import io
import os
import time

base_dir = 'C:/Users/rajab/OneDrive/Desktop/MilliyMetr/assets/images/categories/'
os.makedirs(base_dir, exist_ok=True)

# 29 to 61
categories = [
    (29, 'Heating Systems', 'Radiator (heating)'),
    (30, 'Pumps and Pumping', 'Water pump'),
    (31, 'Water Filters', 'Water filter'),
    (32, 'Smart Home Systems', 'Smart thermostat'),
    (33, 'Cables and Wires', 'Electrical cable'),
    (34, 'Lighting and Fixtures', 'LED lamp'),
    (35, 'Sockets and Switches', 'AC power plugs and sockets'),
    (36, 'Circuit Breakers', 'Circuit breaker'),
    (37, 'Generators', 'Engine-generator'),
    (38, 'Power Tools', 'Power tool'),
    (39, 'Hand Tools', 'Hand tool'),
    (40, 'Measuring Tools', 'Tape measure'),
    (41, 'Abrasives', 'Sandpaper'),
    (42, 'Garden Tools', 'Shovel'),
    (43, 'Landscaping Materials', 'Mulch'),
    (44, 'Paving Stones', 'Sett (paving)'),
    (45, 'Fences and Barriers', 'Fence'),
    (46, 'Polycarbonate', 'Polycarbonate'),
    (47, 'Metal Roll', 'Sheet metal'),
    (48, 'Fittings and Valves', 'Valve'),
    (49, 'Sewage Systems', 'Sewerage'),
    (50, 'Radiators', 'Radiator'),
    (51, 'Underfloor Heating', 'Underfloor heating'),
    (52, 'Plumbing Fixtures', 'Sink'),
    (53, 'Mixers and Faucets', 'Tap (valve)'),
    (54, 'Shower Cabins', 'Shower'),
    (55, 'Bathtubs', 'Bathtub'),
    (56, 'Toilets and Bidets', 'Toilet'),
    (57, 'Bathroom Furniture', 'Bathroom cabinet'),
    (58, 'Water Heaters', 'Water heater'),
    (59, 'Boilers', 'Boiler'),
    (60, 'Air Conditioners', 'Air conditioning'),
    (61, 'Compressors', 'Air compressor')
]

def search_wiki_image(query):
    url = "https://en.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "format": "json",
        "prop": "pageimages",
        "generator": "search",
        "gsrsearch": query,
        "gsrnamespace": "0",
        "gsrlimit": "3",
        "pithumbsize": "800"
    }
    headers = {'User-Agent': 'MilliyMetrBot/1.0 (https://milliymetr.uz; admin@milliymetr.uz)'}
    try:
        response = requests.get(url, params=params, headers=headers, timeout=10)
        data = response.json()
        pages = data.get('query', {}).get('pages', {})
        for page_id, page in pages.items():
            if 'thumbnail' in page:
                return page['thumbnail']['source']
    except Exception as e:
        print(f"  Wiki error for {query}: {e}")
    return None

def process_category(cat_id, name, query):
    out_path = os.path.join(base_dir, f'cat-{cat_id}.webp')
    print(f"Processing cat-{cat_id}: {name}")
    
    img_url = search_wiki_image(query)
    
    if not img_url:
        print(f"  No image found on Wiki for {query}")
        return False
        
    print(f"  Downloading: {img_url}")
    try:
        response = requests.get(img_url, timeout=10, headers={'User-Agent': 'MilliyMetrBot/1.0'})
        if response.status_code == 200:
            img_data = response.content
            
            subject = Image.open(io.BytesIO(img_data)).convert("RGBA")
            
            # Simple magic wand / flood fill for top-left corner to white
            # Create a white background
            bg = Image.new("RGB", (600, 600), (255, 255, 255))
            
            max_dim = 550
            ratio = min(max_dim / subject.width, max_dim / subject.height)
            new_size = (int(subject.width * ratio), int(subject.height * ratio))
            subject = subject.resize(new_size, Image.Resampling.LANCZOS)
            
            # Convert background of subject to white using flood fill if it's somewhat uniform
            # Just pasting it in the center for now, with white background
            offset = ((600 - new_size[0]) // 2, (600 - new_size[1]) // 2)
            bg.paste(subject, offset, subject)
            
            bg.save(out_path, "WEBP", quality=90)
            print(f"  Success: saved to {out_path}")
            return True
    except Exception as e:
        print(f"  Failed: {e}")
        
    return False

for cat in categories:
    process_category(cat[0], cat[1], cat[2])
    time.sleep(1)

print("Finished processing all remaining categories via Wiki.")
