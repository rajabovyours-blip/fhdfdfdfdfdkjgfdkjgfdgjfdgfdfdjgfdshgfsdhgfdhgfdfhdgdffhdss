"""fix certificates type

Revision ID: 6a3b2c1d9e8f
Revises: fbeebc41e0a0
Create Date: 2026-09-03 03:54:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import json

# revision identifiers, used by Alembic.
revision: str = '6a3b2c1d9e8f'
down_revision: Union[str, None] = 'fbeebc41e0a0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Add temporary column
    op.add_column('products', sa.Column('certificates_json', postgresql.JSON(astext_type=sa.Text()), nullable=True))
    
    # 2. Copy data from text to json
    conn = op.get_bind()
    result = conn.execute(sa.text("SELECT id, certificates FROM products WHERE certificates IS NOT NULL"))
    
    for row in result:
        id, cert_text = row
        if cert_text:
            if cert_text.startswith('[') and cert_text.endswith(']'):
                # it's already json string
                try:
                    parsed = json.loads(cert_text)
                    if not isinstance(parsed, list):
                        parsed = [cert_text]
                    conn.execute(sa.text("UPDATE products SET certificates_json = :val WHERE id = :id"), {"val": json.dumps(parsed), "id": id})
                except Exception:
                    conn.execute(sa.text("UPDATE products SET certificates_json = :val WHERE id = :id"), {"val": json.dumps([cert_text]), "id": id})
            else:
                conn.execute(sa.text("UPDATE products SET certificates_json = :val WHERE id = :id"), {"val": json.dumps([cert_text]), "id": id})

    # 3. Drop old column and rename new one
    op.drop_column('products', 'certificates')
    op.alter_column('products', 'certificates_json', new_column_name='certificates')


def downgrade() -> None:
    # Downgrade logic: JSON back to String
    op.add_column('products', sa.Column('certificates_str', sa.String(), nullable=True))
    
    conn = op.get_bind()
    result = conn.execute(sa.text("SELECT id, certificates FROM products WHERE certificates IS NOT NULL"))
    
    for row in result:
        id, cert_json = row
        if cert_json:
            try:
                # cert_json could be dict or string in DB depending on driver, but assuming python dictionary or list if asyncpg
                if isinstance(cert_json, list):
                    val = cert_json[0] if cert_json else ""
                elif isinstance(cert_json, str):
                    parsed = json.loads(cert_json)
                    val = parsed[0] if isinstance(parsed, list) and parsed else cert_json
                else:
                    val = str(cert_json)
                conn.execute(sa.text("UPDATE products SET certificates_str = :val WHERE id = :id"), {"val": val, "id": id})
            except Exception:
                pass

    op.drop_column('products', 'certificates')
    op.alter_column('products', 'certificates_str', new_column_name='certificates')
