from duckduckgo_search import DDGS
import requests
from PIL import Image
import io
import os
import time

base_dir = 'C:/Users/rajab/OneDrive/Desktop/MilliyMetr/assets/images/categories/'
os.makedirs(base_dir, exist_ok=True)

categories = [
    (13, 'Tiles and Ceramics', 'ceramic floor tiles isolated white background photorealistic'),
    (14, 'Doors and Windows', 'wooden interior door isolated white background photorealistic'),
    (15, 'Locks and Hardware', 'door lock cylinder isolated white background photorealistic'),
    (16, 'Floor Coverings', 'laminate flooring planks isolated white background photorealistic'),
    (17, 'Waterproofing', 'waterproofing membrane roll isolated white background photorealistic'),
    (18, 'Glass and Mirrors', 'window glass pane isolated white background photorealistic'),
    (19, 'Construction Adhesives', 'construction adhesive tube isolated white background photorealistic'),
    (20, 'Mounting Foam', 'polyurethane foam can isolated white background photorealistic'),
    (21, 'Fasteners', 'metal screws and nails isolated white background photorealistic'),
    (22, 'Workwear and PPE', 'construction hard hat safety helmet isolated white background photorealistic'),
    (23, 'Ladders and Scaffolding', 'aluminum step ladder isolated white background photorealistic'),
    (24, 'Scaffolding Systems', 'scaffolding frame isolated white background photorealistic'),
    (25, 'Geotextiles', 'geotextile fabric roll isolated white background photorealistic'),
    (26, 'Siding and Facade', 'vinyl siding panels isolated white background photorealistic'),
    (27, 'Gutter Systems', 'rain gutter pipe isolated white background photorealistic'),
    (28, 'Ventilation and AC', 'ventilation fan isolated white background photorealistic'),
    (29, 'Heating Systems', 'heating radiator isolated white background photorealistic'),
    (30, 'Pumps and Pumping', 'water pump isolated white background photorealistic'),
    (31, 'Water Filters', 'water filter cartridge isolated white background photorealistic'),
    (32, 'Smart Home Systems', 'smart home thermostat isolated white background photorealistic'),
    (33, 'Cables and Wires', 'electrical wire cable isolated white background photorealistic'),
    (34, 'Lighting and Fixtures', 'LED light bulb isolated white background photorealistic'),
    (35, 'Sockets and Switches', 'electrical wall socket isolated white background photorealistic'),
    (36, 'Circuit Breakers', 'electrical circuit breaker isolated white background photorealistic'),
    (37, 'Generators', 'portable power generator isolated white background photorealistic'),
    (38, 'Power Tools', 'power drill isolated white background photorealistic'),
    (39, 'Hand Tools', 'hammer wrench hand tools isolated white background photorealistic'),
    (40, 'Measuring Tools', 'tape measure isolated white background photorealistic'),
    (41, 'Abrasives', 'sandpaper disc isolated white background photorealistic'),
    (42, 'Garden Tools', 'garden shovel isolated white background photorealistic'),
    (43, 'Landscaping Materials', 'landscaping mulch isolated white background photorealistic'),
    (44, 'Paving Stones', 'paving stone isolated white background photorealistic'),
    (45, 'Fences and Barriers', 'metal fence panel isolated white background photorealistic'),
    (46, 'Polycarbonate', 'polycarbonate sheet isolated white background photorealistic'),
    (47, 'Metal Roll', 'metal sheet roll isolated white background photorealistic'),
    (48, 'Fittings and Valves', 'plumbing brass valve isolated white background photorealistic'),
    (49, 'Sewage Systems', 'pvc sewage pipe isolated white background photorealistic'),
    (50, 'Radiators', 'heating radiator panel isolated white background photorealistic'),
    (51, 'Underfloor Heating', 'underfloor heating pipe roll isolated white background photorealistic'),
    (52, 'Plumbing Fixtures', 'bathroom sink basin isolated white background photorealistic'),
    (53, 'Mixers and Faucets', 'bathroom faucet isolated white background photorealistic'),
    (54, 'Shower Cabins', 'shower cabin enclosure isolated white background photorealistic'),
    (55, 'Bathtubs', 'white bathtub isolated white background photorealistic'),
    (56, 'Toilets and Bidets', 'ceramic toilet bowl isolated white background photorealistic'),
    (57, 'Bathroom Furniture', 'bathroom vanity cabinet isolated white background photorealistic'),
    (58, 'Water Heaters', 'electric water heater isolated white background photorealistic'),
    (59, 'Boilers', 'gas boiler isolated white background photorealistic'),
    (60, 'Air Conditioners', 'air conditioner split unit isolated white background photorealistic'),
    (61, 'Compressors', 'air compressor isolated white background photorealistic')
]

def process_category(cat_id, name, query):
    out_path = os.path.join(base_dir, f'cat-{cat_id}.webp')
    print(f"Processing cat-{cat_id}: {name}")
    
    try:
        results = DDGS().images(query, max_results=3)
        if not results:
            print(f"  No images found for {query}")
            return False
            
        for result in results:
            url = result['image']
            print(f"  Downloading: {url}")
            try:
                response = requests.get(url, timeout=10)
                if response.status_code == 200:
                    img_data = response.content
                    
                    print("  Formatting onto white background...")
                    subject = Image.open(io.BytesIO(img_data)).convert("RGBA")
                    
                    # Calculate new size to fit inside 500x500
                    max_dim = 500
                    ratio = min(max_dim / subject.width, max_dim / subject.height)
                    new_size = (int(subject.width * ratio), int(subject.height * ratio))
                    subject = subject.resize(new_size, Image.Resampling.LANCZOS)
                    
                    # Create 600x600 white background
                    bg = Image.new("RGB", (600, 600), (255, 255, 255))
                    
                    # Create a composite if the subject has alpha
                    # Paste subject in center using alpha as mask
                    offset = ((600 - new_size[0]) // 2, (600 - new_size[1]) // 2)
                    bg.paste(subject, offset, subject)
                    
                    bg.save(out_path, "WEBP", quality=90)
                    print(f"  Success: saved to {out_path}")
                    return True
            except Exception as e:
                print(f"  Failed with url {url}: {e}")
                continue
                
        print("  All attempts failed for this category.")
        return False
        
    except Exception as e:
        print(f"  Error searching: {e}")
        return False

for cat in categories:
    process_category(cat[0], cat[1], cat[2])
    time.sleep(1) # Be nice to the API

print("Finished processing all remaining categories.")
