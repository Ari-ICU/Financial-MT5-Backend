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
        if not account_id and cls._account_data:
            account_id = list(cls._account_data.keys())[0]

        return cls._account_data.get(account_id, {"status": "error", "message": "No data received yet"})

    @classmethod
    async def disconnect_all(cls) -> None:
        """Clears cache on shutdown"""
        cls._account_data.clear()