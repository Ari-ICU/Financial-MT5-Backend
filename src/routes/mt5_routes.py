from fastapi import APIRouter, Request, HTTPException
import json
from ..services.mt5_service import MT5Service

router = APIRouter(prefix="/mt5", tags=["MT5 Direct"])

@router.post("/update")
async def update_mt5_data(request: Request):
    try:
        # Get raw bytes to handle potential null terminators from MT5
        body_bytes = await request.body()
        # Decode and strip invisible characters that cause "Invalid data format"
        body_str = body_bytes.decode("utf-8").strip().replace('\0', '')
        
        if not body_str:
            raise HTTPException(status_code=400, detail="Empty payload")

        data = json.loads(body_str)
        account_id = str(data.get("login", "unknown"))
        
        return await MT5Service.update_account_info(account_id, data)
    except Exception as e:
        # This catch-all prevents the 400 error from crashing the bridge
        return {"status": "error", "message": str(e)}

@router.get("/account")
async def get_account(account_id: str = None):
    return await MT5Service.get_account_info(account_id)