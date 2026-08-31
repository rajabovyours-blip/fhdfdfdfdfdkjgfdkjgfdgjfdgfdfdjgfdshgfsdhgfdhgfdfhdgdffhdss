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


from sqlalchemy.engine.reflection import Inspector

def upgrade() -> None:
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    users_columns = [col['name'] for col in inspector.get_columns('users')]

    if 'provider' not in users_columns:
        op.add_column('users', sa.Column('provider', sa.String(length=50), nullable=True))
    if 'provider_id' not in users_columns:
        op.add_column('users', sa.Column('provider_id', sa.String(length=255), nullable=True))

def downgrade() -> None:
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    users_columns = [col['name'] for col in inspector.get_columns('users')]

    if 'provider_id' in users_columns:
        op.drop_column('users', 'provider_id')
    if 'provider' in users_columns:
        op.drop_column('users', 'provider')
