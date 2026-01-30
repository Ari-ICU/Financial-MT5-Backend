#==============================================================================
# MT5 API Routes
# Like MQL5 Event Handlers (OnInit, OnTick) - Endpoint definitions
#==============================================================================

from fastapi import APIRouter, HTTPException
from typing import Optional

from ..models.schemas import (
    MT5ConnectionRequest,
    MT5ConnectionResponse,
    MT5StatusResponse,
    MT5AccountInfoResponse
)
from ..services.mt5_service import MT5Service


# Initialize router
router = APIRouter(
    prefix="/mt5",
    tags=["MT5"],
    responses={
        404: {"description": "Not found"},
        500: {"description": "Internal server error"}
    }
)


# =============================================================================
# MT5 Connection Endpoints
# =============================================================================

@router.post("/connect", response_model=MT5ConnectionResponse)
async def connect_to_mt5(request: MT5ConnectionRequest):
    """
    Connect to MT5 account via MetaAPI
    Like: int OnInit() in MQL5 Expert Advisor
    
    Args:
        request: Connection request with account_id
        
    Returns:
        Connection response with status and account info
    """
    return await MT5Service.connect_account(request.account_id)


@router.get("/status", response_model=MT5StatusResponse)
async def get_connection_status():
    """
    Get current MT5 connection status
    Like: string GetStatus() in MQL5
    
    Returns:
        Current connection status and list of connected accounts
    """
    return await MT5Service.get_connection_status()


@router.get("/account", response_model=MT5AccountInfoResponse)
async def get_account_information(account_id: Optional[str] = None):
    """
    Retrieve account information from MetaApi
    Like: void OnTimer() -> GetAccountInfo() in MQL5
    
    Args:
        account_id: Optional account ID (uses default from env if not provided)
        
    Returns:
        Account information including balance, equity, etc.
    """
    return await MT5Service.get_account_info(account_id)


@router.delete("/disconnect/{account_id}")
async def disconnect_from_mt5(account_id: str):
    """
    Disconnect from MT5 account
    Like: void OnDeinit(const int reason) in MQL5
    
    Args:
        account_id: Account ID to disconnect
        
    Returns:
        Disconnect status
    """
    success = await MT5Service.disconnect_account(account_id)
    if success:
        return {"status": "disconnected", "account_id": account_id}
    else:
        raise HTTPException(
            status_code=404, 
            detail=f"Account {account_id} not found or already disconnected"
        )
