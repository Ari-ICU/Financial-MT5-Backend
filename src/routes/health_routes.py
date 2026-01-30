#==============================================================================
# Health Check Routes
# Like MQL5 System Functions - Basic status checks
#==============================================================================

from fastapi import APIRouter
from datetime import datetime

from ..models.schemas import HealthCheckResponse


# Initialize router
router = APIRouter(
    tags=["Health"],
    responses={404: {"description": "Not found"}}
)


# =============================================================================
# Health Check Endpoints
# =============================================================================

@router.get("/", response_model=HealthCheckResponse)
async def root():
    """
    Root health check endpoint
    Like: bool IsConnected() in MQL5
    
    Returns:
        Service health status
    """
    return {
        "status": "ok",
        "service": "financial-backend",
        "timestamp": datetime.utcnow().isoformat()
    }


@router.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """
    Detailed health check endpoint
    Like: void GetSystemInfo() in MQL5
    
    Returns:
        Detailed service health status
    """
    return {
        "status": "healthy",
        "service": "financial-backend",
        "timestamp": datetime.utcnow().isoformat()
    }
