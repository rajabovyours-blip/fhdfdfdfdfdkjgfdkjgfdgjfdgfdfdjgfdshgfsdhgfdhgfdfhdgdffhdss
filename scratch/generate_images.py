from PIL import Image, ImageDraw, ImageFont
import os
import glob

base_dir = 'C:/Users/rajab/OneDrive/Desktop/MilliyMetr/assets/images/categories/'
gemini_dir = 'C:/Users/rajab/.gemini/antigravity-ide/brain/7fcbc63a-6020-4740-97d4-64289efb8f1a/'

categories = [
    (1, 'Bricks and Blocks'),
    (2, 'Cement and Mixtures'),
    (3, 'Lumber'),
    (4, 'Rebar and Metal'),
    (5, 'Roofing Materials'),
    (6, 'Thermal Insulation'),
    (7, 'Paints and Varnishes'),
    (8, 'Plumbing'),
    (9, 'Electrical Equipment'),
    (10, 'Construction Tools'),
    (11, 'Sand and Gravel'),
    (12, 'Drywall and Profiles'),
    (13, 'Tiles and Ceramics'),
    (14, 'Doors and Windows'),
    (15, 'Locks and Hardware'),
    (16, 'Floor Coverings'),
    (17, 'Waterproofing'),
    (18, 'Glass and Mirrors'),
    (19, 'Construction Adhesives'),
    (20, 'Mounting Foam'),
    (21, 'Fasteners'),
    (22, 'Workwear and PPE'),
    (23, 'Ladders and Scaffolding'),
    (24, 'Scaffolding Systems'),
    (25, 'Geotextiles'),
    (26, 'Siding and Facade'),
    (27, 'Gutter Systems'),
    (28, 'Ventilation and AC'),
    (29, 'Heating Systems'),
    (30, 'Pumps and Pumping'),
    (31, 'Water Filters'),
    (32, 'Smart Home Systems'),
    (33, 'Cables and Wires'),
    (34, 'Lighting and Fixtures'),
    (35, 'Sockets and Switches'),
    (36, 'Circuit Breakers'),
    (37, 'Generators'),
    (38, 'Power Tools'),
    (39, 'Hand Tools'),
    (40, 'Measuring Tools'),
    (41, 'Abrasives'),
    (42, 'Garden Tools'),
    (43, 'Landscaping Materials'),
    (44, 'Paving Stones'),
    (45, 'Fences and Barriers'),
    (46, 'Polycarbonate'),
    (47, 'Metal Roll'),
    (48, 'Fittings and Valves'),
    (49, 'Sewage Systems'),
    (50, 'Radiators'),
    (51, 'Underfloor Heating'),
    (52, 'Plumbing Fixtures'),
    (53, 'Mixers and Faucets'),
    (54, 'Shower Cabins'),
    (55, 'Bathtubs'),
    (56, 'Toilets and Bidets'),
    (57, 'Bathroom Furniture'),
    (58, 'Water Heaters'),
    (59, 'Boilers'),
    (60, 'Air Conditioners'),
    (61, 'Compressors')
]

# Ensure directory exists
os.makedirs(base_dir, exist_ok=True)

for cat_id, cat_name in categories:
    out_path = os.path.join(base_dir, f'cat-{cat_id}.webp')
    
    # Check if we have an AI generated image
    search_pattern = os.path.join(gemini_dir, f'cat_{cat_id}_*.jpg')
    matches = glob.glob(search_pattern)
    
    if matches:
        # Use AI image
        img_path = matches[0]
        try:
            with Image.open(img_path) as img:
                img.save(out_path, 'WEBP')
                print(f'Saved AI image for cat-{cat_id}')
        except Exception as e:
            print(f'Failed to process {img_path}: {e}')
    else:
        # Generate premium placeholder
        img = Image.new('RGB', (512, 512), color=(255, 255, 255))
        draw = ImageDraw.Draw(img)
        
        # Try to load a standard font
        try:
            # Use arial if available, else default
            font = ImageFont.truetype("arial.ttf", 36)
        except:
            font = ImageFont.load_default()
            
        # Draw text in center
        text = cat_name
        # Break text into multiple lines if too long
        words = text.split()
        lines = []
        current_line = []
        for word in words:
            current_line.append(word)
            # Estimate width
            if len(" ".join(current_line)) > 15:
                lines.append(" ".join(current_line))
                current_line = []
        if current_line:
            lines.append(" ".join(current_line))
            
        y_text = 200
        for line in lines:
            # Calculate text bounding box
            left, top, right, bottom = draw.textbbox((0, 0), line, font=font)
            width = right - left
            draw.text(((512 - width) / 2, y_text), line, font=font, fill=(50, 50, 50))
            y_text += 50
            
        # Draw a simple border to make it look like a product card
        draw.rectangle([20, 20, 492, 492], outline=(220, 220, 220), width=2)
        
        img.save(out_path, 'WEBP')
        print(f'Generated placeholder for cat-{cat_id}')

print("Done generating 61 images.")
