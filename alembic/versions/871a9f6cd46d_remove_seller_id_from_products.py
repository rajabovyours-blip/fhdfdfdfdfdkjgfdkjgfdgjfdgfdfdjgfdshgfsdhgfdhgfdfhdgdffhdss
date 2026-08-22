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


def upgrade() -> None:
    """Upgrade schema."""
    op.drop_constraint('products_seller_id_fkey', 'products', type_='foreignkey')
    op.drop_column('products', 'seller_id')


def downgrade() -> None:
    """Downgrade schema."""
    op.add_column('products', sa.Column('seller_id', sa.UUID(), autoincrement=False, nullable=True))
    op.create_foreign_key('products_seller_id_fkey', 'products', 'users', ['seller_id'], ['id'])
