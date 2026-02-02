# src/mt5_service.py
from typing import Dict, Optional

class MT5Service:
    # Memory store: { "270716956": { "balance": 1000, "equity": 1050, ... } }
    _account_data: Dict[str, Dict] = {}

    @classmethod
    async def update_account_info(cls, account_id: str, data: Dict) -> Dict:
        """Saves the data dictionary from MQL5"""
        cls._account_data[account_id] = data
        return {
            "status": "success", 
            "account_id": account_id,
            "fields_updated": list(data.keys())
        }

    @classmethod
    async def get_account_info(cls, account_id: Optional[str] = None) -> Dict:
        if not account_id:
            return {"status": "error", "message": "No account selected"}

        return cls._account_data.get(account_id, {
            "status": "error", 
            "message": f"No data received yet for account {account_id}"
        })

    @classmethod
    async def get_connection_status(cls) -> Dict:
        if not cls._account_data:
            return {
                "status": "disconnected",
                "connected_accounts": []
            }
        
        return {
            "status": "connected",
            "connected_accounts": list(cls._account_data.keys())
        }

    @classmethod
    async def get_active_logins(cls) -> list:
        return list(cls._account_data.keys())

    @classmethod
    async def disconnect_all(cls) -> None:
        cls._account_data.clear()

    @classmethod
    async def perform_trade(cls, action: str, account_id: str, volume: float = 0.01) -> Dict:
        """Simulate performing a trade action. In a real system this would forward the request to the EA via HTTP or a message queue."""
        # Basic validation
        if account_id not in cls._account_data:
            return {"status": "error", "message": f"No such account: {account_id}"}

        valid = {"buy", "sell", "close_profit", "close_loss", "close_all"}
        if action not in valid:
            return {"status": "error", "message": f"Invalid action: {action}"}

        # Simulated response; we don't mutate real positions here.
        return {
            "status": "ok",
            "account_id": account_id,
            "action": action,
            "volume": volume,
            "message": f"Simulated {action} on {account_id} (volume {volume})"
        }