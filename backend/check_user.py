import sqlite3
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

conn = sqlite3.connect('milliy_metr.db')
c = conn.cursor()
c.execute("SELECT username, role, hashed_password, is_active FROM users WHERE username = 'manga_qaralarin'")
row = c.fetchone()
print("DB ROW:", row)

if row:
    is_valid = pwd_context.verify('achika1337', row[2])
    print("Password valid?", is_valid)
else:
    print("User not found in DB.")
conn.close()
