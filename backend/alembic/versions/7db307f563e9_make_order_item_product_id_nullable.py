"""make_order_item_product_id_nullable

Revision ID: 7db307f563e9
Revises: 6a3b2c1d9e8f
Create Date: 2026-09-07 00:32:19.988218

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '7db307f563e9'
down_revision: Union[str, Sequence[str], None] = '6a3b2c1d9e8f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    with op.batch_alter_table('order_items') as batch_op:
        batch_op.alter_column('product_id',
                   existing_type=sa.UUID(),
                   nullable=True)


def downgrade() -> None:
    """Downgrade schema."""
    with op.batch_alter_table('order_items') as batch_op:
        batch_op.alter_column('product_id',
                   existing_type=sa.UUID(),
                   nullable=False)
