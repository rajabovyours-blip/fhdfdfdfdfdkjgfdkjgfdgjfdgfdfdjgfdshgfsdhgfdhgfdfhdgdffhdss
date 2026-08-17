from pydantic import BaseModel, UUID4
from typing import List, Optional
from datetime import datetime

class AdminDashboardSummary(BaseModel):
    total_users: int
    total_orders: int
    total_revenue: float

class AdminActionRequest(BaseModel):
    action: str # approve, reject, suspend
    reason: Optional[str] = None
