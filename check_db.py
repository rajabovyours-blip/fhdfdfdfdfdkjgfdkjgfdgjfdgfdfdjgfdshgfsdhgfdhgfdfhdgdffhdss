import sqlite3
import json

conn = sqlite3.connect('backend/test.db')
conn.row_factory = sqlite3.Row
c = conn.cursor()
c.execute('SELECT id, name, price, stock, rating, discount_price FROM products')
rows = c.fetchall()
for r in rows:
    print(dict(r))
