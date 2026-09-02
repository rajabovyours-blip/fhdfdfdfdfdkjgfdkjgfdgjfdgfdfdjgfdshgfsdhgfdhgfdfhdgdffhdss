import sqlite3
conn = sqlite3.connect('milliy_metr.db')
try:
    conn.execute('ALTER TABLE users ADD COLUMN preferred_language VARCHAR DEFAULT "uz"')
    conn.commit()
    print('Column added.')
except Exception as e:
    print('Failed to add column:', e)
conn.close()
