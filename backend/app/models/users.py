import uuid
from sqlalchemy import Column, String, Boolean, ForeignKey, Integer, Table, Text
from sqlalchemy.orm import relationship
from sqlalchemy import Uuid
from app.models.base import Base, TimestampMixin

# Association table for role-permissions
role_permissions = Table(
    "role_permissions",
    Base.metadata,
    Column("role_id", Uuid(as_uuid=True), ForeignKey("roles.id", ondelete="CASCADE"), primary_key=True),
    Column("permission_id", Uuid(as_uuid=True), ForeignKey("permissions.id", ondelete="CASCADE"), primary_key=True)
)

class Permission(Base, TimestampMixin):
    __tablename__ = "permissions"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(50), unique=True, nullable=False, index=True) # e.g. "product:read", "admin:all"
    description = Column(String(255))
    
    roles = relationship("Role", secondary=role_permissions, back_populates="permissions")

class Role(Base, TimestampMixin):
    __tablename__ = "roles"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(50), unique=True, nullable=False, index=True) # e.g. "customer", "admin"
    description = Column(String(255))
    
    permissions = relationship("Permission", secondary=role_permissions, back_populates="roles")
    users = relationship("User", back_populates="role")

class User(Base, TimestampMixin):
    __tablename__ = "users"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    phone = Column(String(20), unique=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)
    role_id = Column(Uuid(as_uuid=True), ForeignKey("roles.id"), nullable=True)
    provider = Column(String(50), nullable=True)
    provider_id = Column(String(255), nullable=True)

    role = relationship("Role", back_populates="users")
    addresses = relationship("Address", back_populates="user", cascade="all, delete-orphan")
    orders = relationship("Order", back_populates="user")
    reviews = relationship("Review", back_populates="user")

class Address(Base, TimestampMixin):
    __tablename__ = "addresses"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(50), nullable=False) # e.g. Home, Work
    address_line_1 = Column(Text, nullable=False)
    city = Column(String(100), nullable=False)
    region = Column(String(100), nullable=False)
    postal_code = Column(String(20))
    is_default = Column(Boolean, default=False)

    user = relationship("User", back_populates="addresses")
