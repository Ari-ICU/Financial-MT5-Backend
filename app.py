#==============================================================================
# Financial Backend API - Main Application
# Clean Structure Like MQL5 Expert Advisor
# 
# Structure:
#   - config/     : Settings and configuration (like input parameters)
#   - models/     : Data models (like structures)
#   - services/   : Business logic (like functions)
#   - routes/     : API endpoints (like event handlers)
#   - middlewares/: Request/response processing
#   - utils/      : Helper functions
#==============================================================================

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from contextlib import asynccontextmanager

from src.config.settings import settings
from src.routes import mt5_routes, health_routes
from src.services.mt5_service import MT5Service
from src.middlewares.error_handler import (
    validation_exception_handler,
    general_exception_handler
)
from src.utils.logger import logger, AppLogger


# =============================================================================
# Lifespan Context Manager (Startup/Shutdown Events)
# Like OnInit() and OnDeinit() in MQL5
# =============================================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager
    Like: OnInit() and OnDeinit() in MQL5 EA
    """
    # Startup - Like OnInit()
    # Update this dictionary to remove METAAPI_TOKEN
    AppLogger.log_startup(logger, {
        "APP_TITLE": settings.APP_TITLE,
        "APP_VERSION": settings.APP_VERSION,
        "CORS_ORIGINS": settings.CORS_ORIGINS
    })
    
    # Logic to initialize any local resources if needed
    logger.info("✅ Direct MQL5 Bridge Mode Active (No MetaApi)")
    
    yield
    
    # Shutdown - Like OnDeinit()
    AppLogger.log_shutdown(logger)
    await MT5Service.disconnect_all()

# =============================================================================
# Initialize FastAPI Application
# Like Expert Advisor Initialization
# =============================================================================

app = FastAPI(
    title=settings.APP_TITLE,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
    lifespan=lifespan
)


# =============================================================================
# Configure Middleware
# Like Setting Up EA Properties
# =============================================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=settings.CORS_CREDENTIALS,
    allow_methods=settings.CORS_METHODS,
    allow_headers=settings.CORS_HEADERS,
)


# =============================================================================
# Register Exception Handlers
# Like MQL5 Error Handling
# =============================================================================

app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, general_exception_handler)


# =============================================================================
# Register Routes
# Like Registering Event Handlers in MQL5
# =============================================================================

app.include_router(health_routes.router)
app.include_router(mt5_routes.router)


# =============================================================================
# Development Server Runner
# Like Running in Strategy Tester
# =============================================================================

if __name__ == "__main__":
    import uvicorn
    
    logger.info("Starting development server...")
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8001,  # Set this to 8002
        reload=True,
        log_level="info"
    )