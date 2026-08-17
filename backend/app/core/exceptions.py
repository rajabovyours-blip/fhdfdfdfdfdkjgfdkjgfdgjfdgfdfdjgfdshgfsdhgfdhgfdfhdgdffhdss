from fastapi import Request, status
from fastapi.responses import JSONResponse
import structlog

logger = structlog.get_logger(__name__)

class AppError(Exception):
    def __init__(self, message: str, code: str, status_code: int = 400, details: dict | None = None):
        self.message = message
        self.code = code
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)

async def app_error_handler(request: Request, exc: AppError):
    logger.error("application_error", code=exc.code, error=exc.message, path=request.url.path)
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "details": exc.details
            }
        }
    )

async def global_exception_handler(request: Request, exc: Exception):
    logger.exception("unhandled_exception", error=str(exc), path=request.url.path)
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "An unexpected error occurred.",
                "details": {}
            }
        }
    )
