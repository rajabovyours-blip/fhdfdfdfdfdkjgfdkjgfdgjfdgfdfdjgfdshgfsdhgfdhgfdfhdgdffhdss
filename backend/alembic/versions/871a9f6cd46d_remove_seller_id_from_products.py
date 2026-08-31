"""remove_seller_id_from_products

Revision ID: 871a9f6cd46d
Revises: 58a45a364663
Create Date: 2026-08-22 23:04:25.384047

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '871a9f6cd46d'
down_revision: Union[str, Sequence[str], None] = '58a45a364663'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


from sqlalchemy.engine.reflection import Inspector

def upgrade() -> None:
    """Upgrade schema."""
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    products_columns = [col['name'] for col in inspector.get_columns('products')]

    if 'seller_id' in products_columns:
        fks = [fk['name'] for fk in inspector.get_foreign_keys('products')]
        if 'products_seller_id_fkey' in fks:
            op.drop_constraint('products_seller_id_fkey', 'products', type_='foreignkey')
        op.drop_column('products', 'seller_id')


def downgrade() -> None:
    """Downgrade schema."""
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    products_columns = [col['name'] for col in inspector.get_columns('products')]

    if 'seller_id' not in products_columns:
        op.add_column('products', sa.Column('seller_id', sa.UUID(), autoincrement=False, nullable=True))
        op.create_foreign_key('products_seller_id_fkey', 'products', 'users', ['seller_id'], ['id'])
