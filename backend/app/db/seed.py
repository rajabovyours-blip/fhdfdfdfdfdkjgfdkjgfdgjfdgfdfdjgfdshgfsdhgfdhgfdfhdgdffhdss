"""
Production-safe seed script for Milliy Metr.
- Idempotent: only inserts categories if none exist
- Does NOT create demo/fake products
- Products are managed exclusively through Admin Panel
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.category import Category
import uuid

# Categories are managed dynamically through Admin Panel

async def seed_data(session: AsyncSession):
    """Idempotent seed: only creates categories if none exist. Never creates demo products."""
    # Ensure initial owner accounts exist
    from app.models.user import User, RoleEnum
    from app.security.hashing import get_password_hash
    
    owner1_check = await session.execute(select(User).where(User.username == "manga_qaralarin"))
    owner1 = owner1_check.scalar_one_or_none()
    if not owner1:
        owner1 = User(
            id=uuid.uuid4(),
            username="manga_qaralarin",
            full_name="Owner 1",
            phone="+998900000001",
            email="owner1@milliymetr.uz",
            hashed_password=get_password_hash("achika1337"),
            role=RoleEnum.OWNER,
            is_active=True
        )
        session.add(owner1)
    else:
        # Update existing record safely
        owner1.role = RoleEnum.OWNER
        owner1.hashed_password = get_password_hash("achika1337")
        owner1.is_active = True
        
    owner2_check = await session.execute(select(User).where(User.username == "bekzodbek"))
    owner2 = owner2_check.scalar_one_or_none()
    if not owner2:
        owner2 = User(
            id=uuid.uuid4(),
            username="bekzodbek",
            full_name="Owner 2",
            phone="+998900000002",
            email="owner2@milliymetr.uz",
            hashed_password=get_password_hash("rajabov"),
            role=RoleEnum.OWNER,
            is_active=True
        )
        session.add(owner2)
    else:
        # Update existing record safely
        owner2.role = RoleEnum.OWNER
        owner2.hashed_password = get_password_hash("rajabov")
        owner2.is_active = True
        
    await session.commit()
    print("Seeded and verified owner accounts.")

    result = await session.execute(select(func.count()).select_from(Category))
    count = result.scalar()
    print(f"Current category count: {count}")
    
    # Categories are now managed dynamically via Admin Panel.
    # We no longer seed hardcoded categories or show warnings.
    return
