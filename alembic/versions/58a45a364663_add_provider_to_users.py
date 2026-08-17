"""add_provider_to_users

Revision ID: 58a45a364663
Revises: 
Create Date: 2026-08-15 03:30:27.582398

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '58a45a364663'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('users', sa.Column('provider', sa.String(length=50), nullable=True))
    op.add_column('users', sa.Column('provider_id', sa.String(length=255), nullable=True))

def downgrade() -> None:
    op.drop_column('users', 'provider_id')
    op.drop_column('users', 'provider')
