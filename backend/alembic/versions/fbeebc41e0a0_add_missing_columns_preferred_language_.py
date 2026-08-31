"""Add missing columns: preferred_language, delivery_price

Revision ID: fbeebc41e0a0
Revises: 871a9f6cd46d
Create Date: 2026-09-01 03:55:58.917163

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'fbeebc41e0a0'
down_revision: Union[str, Sequence[str], None] = '871a9f6cd46d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


from sqlalchemy.engine.reflection import Inspector

def upgrade() -> None:
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    
    # Check users table
    users_columns = [col['name'] for col in inspector.get_columns('users')]
    if 'preferred_language' not in users_columns:
        op.add_column('users', sa.Column('preferred_language', sa.String(length=10), server_default='uz'))
        
    # Check products table
    products_columns = [col['name'] for col in inspector.get_columns('products')]
    if 'brand' not in products_columns:
        op.add_column('products', sa.Column('brand', sa.String(), nullable=True))
    if 'has_delivery' not in products_columns:
        op.add_column('products', sa.Column('has_delivery', sa.Boolean(), server_default='true'))
    if 'location' not in products_columns:
        op.add_column('products', sa.Column('location', sa.String(), nullable=True))
    if 'delivery_price' not in products_columns:
        op.add_column('products', sa.Column('delivery_price', sa.Numeric(precision=12, scale=2), server_default='0.0'))


def downgrade() -> None:
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    
    products_columns = [col['name'] for col in inspector.get_columns('products')]
    if 'delivery_price' in products_columns:
        op.drop_column('products', 'delivery_price')
    if 'location' in products_columns:
        op.drop_column('products', 'location')
    if 'has_delivery' in products_columns:
        op.drop_column('products', 'has_delivery')
    if 'brand' in products_columns:
        op.drop_column('products', 'brand')
        
    users_columns = [col['name'] for col in inspector.get_columns('users')]
    if 'preferred_language' in users_columns:
        op.drop_column('users', 'preferred_language')
