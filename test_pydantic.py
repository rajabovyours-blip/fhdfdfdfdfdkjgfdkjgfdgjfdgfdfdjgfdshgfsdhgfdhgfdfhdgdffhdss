from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from uuid import uuid4

class OrderUserModel(BaseModel):
    id: str
    full_name: str
    phone_number: Optional[str] = Field(default=None, validation_alias="phone")
    
    model_config = ConfigDict(from_attributes=True)

class FakeUser:
    def __init__(self):
        self.id = str(uuid4())
        self.full_name = "Test"
        self.phone = "12345"

try:
    user = FakeUser()
    model = OrderUserModel.model_validate(user)
    print("Success!", model.model_dump())
except Exception as e:
    print("Error!", str(e))
