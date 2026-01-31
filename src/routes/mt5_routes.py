from fastapi import APIRouter, Request, Response, HTTPException
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

@router.get("/active-id")
async def get_active_id(request: Request):
    active_id = request.cookies.get("mt5_id")
    return {"active_account_id": active_id}

@router.get("/account")
async def get_account(response: Response, account_id: str = None):
    # 1. Fetch data first
    data = await MT5Service.get_account_info(account_id)
    
    # 2. Only set the active-id cookie if the account is known
    if account_id and data.get("status") != "error":
        response.set_cookie(
            key="mt5_id", 
            value=account_id, 
            httponly=True,
            samesite="lax",
            max_age=3600 # 1 hour session
        )
    return data

@router.get("/status")
async def get_status():
    logins = await MT5Service.get_active_logins()
    return {
        "status": "connected" if logins else "disconnected",
        "recent_logins": logins
    }