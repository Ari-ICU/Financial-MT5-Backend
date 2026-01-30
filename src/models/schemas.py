#==============================================================================
# Data Models and Schemas
# Like MQL5 Structures - Type definitions for data
#==============================================================================

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime


class MT5ConnectionRequest(BaseModel):
    """
    Request model for MT5 connection
    Like: struct ConnectionRequest in MQL5
    """
    account_id: str = Field(..., description="MetaAPI Account ID")


class MT5ConnectionResponse(BaseModel):
    """
    Response model for MT5 connection
    Like: struct ConnectionResponse in MQL5
    """
    status: str
    account_id: str
    account_info: Dict[str, Any]


class MT5StatusResponse(BaseModel):
    """
    Response model for MT5 status
    Like: struct StatusInfo in MQL5
    """
    status: str
    connected_accounts: list


class MT5AccountInfoResponse(BaseModel):
    """
    Response model for account information
    Like: struct AccountInfo in MQL5
    """
    account_id: str
    info: Dict[str, Any]


class HealthCheckResponse(BaseModel):
    """
    Response model for health check
    Like: struct HealthInfo in MQL5
    """
    status: str
    service: str
    timestamp: Optional[str] = None


class ErrorResponse(BaseModel):
    """
    Standard error response
    Like: struct ErrorInfo in MQL5
    """
    error: str
    detail: Optional[str] = None
    timestamp: Optional[str] = None
