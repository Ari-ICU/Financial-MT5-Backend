from fastapi import APIRouter, HTTPException, Body
#                             ^^^^  added here

from pydantic import BaseModel
from typing import Optional, Dict, List
from datetime import datetime

from src.services.mt5_service import MT5Service

router = APIRouter(prefix="/mt5", tags=["MT5"])

# Global variable (simple for now – later use Redis or proper state)
active_account_id: Optional[str] = None


class SetActiveRequest(BaseModel):
    account_id: str


@router.post("/update")
@router.post("/heartbeat")  # optional alias in case EA uses different path
async def update_mt5_account(payload: Dict = Body(...)):
    """
    Receives heartbeat/account info from MT5 EA
    """
    login = str(payload.get("login", ""))
    if not login:
        return {"status": "error", "message": "Missing 'login' field in payload"}

    result = await MT5Service.update_account_info(login, payload)

    return {
        "status": "success",
        "message": f"Updated data for account {login}",
        **result
    }


@router.post("/set-active")
async def set_active_account(req: SetActiveRequest):
    """
    UI calls this when user selects/changes account
    """
    global active_account_id
    cleaned_id = req.account_id.strip()
    if not cleaned_id.isdigit():
        raise HTTPException(400, detail="Account ID must be numeric")
    
    active_account_id = cleaned_id
    
    return {
        "status": "ok",
        "message": f"Active account set to {active_account_id}. Data should appear in ~5–15 seconds.",
        "active_account_id": active_account_id
    }


@router.get("/active-id")
async def get_active_id():
    """EA calls this to know which account is currently selected in UI"""
    return {"active_account_id": active_account_id}


@router.get("/account")
async def get_account(account_id: Optional[str] = None):
    if not account_id:
        return {"status": "error", "message": "account_id parameter is required"}
    
    data = await MT5Service.get_account_info(account_id)
    return data


@router.get("/status")
async def get_status():
    data = await MT5Service.get_connection_status()
    recent = await MT5Service.get_active_logins()
    
    # Optional: sort by name or something if you add timestamps later
    return {
        **data,
        "recent_logins": sorted(recent),  # or reverse if you want newest first
        "active_account_id": active_account_id,
        "last_updated": datetime.utcnow().isoformat()  # optional
    }