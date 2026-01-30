#==============================================================================
# Error Handler Middleware
# Like MQL5 Error Handling - Centralized error management
#==============================================================================

from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from datetime import datetime
import traceback

from ..utils.logger import logger


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    Handle validation errors
    Like: HandleValidationError() in MQL5
    
    Args:
        request: FastAPI request
        exc: Validation exception
        
    Returns:
        JSON error response
    """
    logger.error(f"Validation error: {exc.errors()}")
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": "Validation Error",
            "detail": exc.errors(),
            "timestamp": datetime.utcnow().isoformat()
        }
    )


async def general_exception_handler(request: Request, exc: Exception):
    """
    Handle general exceptions
    Like: HandleGeneralError() in MQL5
    
    Args:
        request: FastAPI request
        exc: Exception
        
    Returns:
        JSON error response
    """
    logger.error(f"Unhandled exception: {str(exc)}")
    logger.error(traceback.format_exc())
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "Internal Server Error",
            "detail": str(exc),
            "timestamp": datetime.utcnow().isoformat()
        }
    )
