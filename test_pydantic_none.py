from pydantic import BaseModel, ConfigDict

class TestModel(BaseModel):
    subtotal: float = 0.0
    model_config = ConfigDict(from_attributes=True)

class FakeDB:
    def __init__(self):
        self.subtotal = None

try:
    model = TestModel.model_validate(FakeDB())
    print("Success!", model.model_dump())
except Exception as e:
    print("Error!", str(e))
