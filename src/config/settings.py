#==============================================================================
# Configuration Settings
# Like MQL5 Input Parameters - Centralized Configuration
#==============================================================================

import os
from pathlib import Path
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

# Load environment variables
env_path = Path(__file__).parent.parent.parent / 'env' / '.env'
if env_path.exists():
    load_dotenv(dotenv_path=env_path)
else:
    load_dotenv()


class Settings(BaseSettings):
    """
    Application Settings
    Similar to MQL5 input parameters - all configuration in one place
    """
    
    # =============================================================================
    # API Configuration
    # =============================================================================
    APP_TITLE: str = "Financial Backend API"
    APP_DESCRIPTION: str = "Financial Backend API for MetaTrader 5 using MetaApi SDK"
    APP_VERSION: str = "1.0.0"
    
    # =============================================================================
    # CORS Configuration
    # =============================================================================
    CORS_ORIGINS: list = ["http://localhost:3000", "http://127.0.0.1:3000"]
    CORS_CREDENTIALS: bool = True
    CORS_METHODS: list = ["*"]
    CORS_HEADERS: list = ["*"]
    
    # =============================================================================
    # Connection Configuration
    # =============================================================================
    CONNECTION_TIMEOUT: int = 30
    SYNC_TIMEOUT: int = 60
    
    class Config:
        case_sensitive = True


# Initialize settings instance
settings = Settings()
