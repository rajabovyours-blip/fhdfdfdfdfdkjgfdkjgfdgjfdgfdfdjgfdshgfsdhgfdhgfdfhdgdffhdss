import pandas as pd
import os

data = {
    "name": ["Sement 50kg (Namuna)", "Bolgarka (Namuna)"],
    "description": ["Yuqori sifatli sement, 50kg qopda", "1200W, 11000 aylanish/min"],
    "category": ["Qurilish materiallari", "Qurilish asboblari"],
    "price": [45000, 350000],
    "old_price": [50000, 0],
    "stock": [100, 20],
    "sku": ["SMNT-50-01", "BLG-1200"],
    "brand": ["Quvasoy", "Bosch"],
    "unit": ["qop", "dona"]
}

df = pd.DataFrame(data)

# Create assets directory if it doesn't exist
assets_dir = r"C:\Users\rajab\OneDrive\Desktop\MilliyMetr\milliy_metr_admin\assets"
os.makedirs(assets_dir, exist_ok=True)

excel_path = os.path.join(assets_dir, "mahsulotlar_andozasi.xlsx")

# Save to Excel
with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
    df.to_excel(writer, index=False, sheet_name="Mahsulotlar")
    
    # Auto-adjust columns width
    worksheet = writer.sheets["Mahsulotlar"]
    for column_cells in worksheet.columns:
        length = max(len(str(cell.value)) for cell in column_cells)
        worksheet.column_dimensions[column_cells[0].column_letter].width = length + 2

print(f"Excel template created at {excel_path}")
