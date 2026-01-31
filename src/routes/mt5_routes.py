from fastapi import APIRouter, Request, HTTPException
import json
from ..services.mt5_service import MT5Service
from ..models.schemas import MT5StatusResponse

router = APIRouter(prefix="/mt5", tags=["MT5 Direct"])

@router.post("/update")
async def update_mt5_data(request: Request):
    try:
        # Get raw bytes to handle potential null terminators from MT5
        body_bytes = await request.body()
        # Decode and strip invisible characters that cause parsing errors
        body_str = body_bytes.decode("utf-8").strip().replace('\0', '')
        
        if not body_str:
            return {"status": "error", "message": "400: Empty payload"}

        data = json.loads(body_str)
        # Extract 'login' to use as the unique account identifier
        account_id = str(data.get("login", "unknown"))
        
        return await MT5Service.update_account_info(account_id, data)
    except Exception as e:
        return {"status": "error", "message": str(e)}

@router.get("/account")
async def get_account(account_id: str = None):
    return await MT5Service.get_account_info(account_id)

@router.get("/status", response_model=MT5StatusResponse)
async def get_status():
    """
    Get current MT5 connection status
    Like: string GetStatus() in MQL5
    """
    # This calls the service to return active connections from the cache
    return await MT5Service.get_connection_status()