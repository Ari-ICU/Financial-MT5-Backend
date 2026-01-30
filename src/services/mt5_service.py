#==============================================================================
# MT5 Service Layer
# Like MQL5 Functions - Business logic separated from endpoints
#==============================================================================

import asyncio
from typing import Dict, Optional
from metaapi_cloud_sdk import MetaApi
from fastapi import HTTPException

from ..config.settings import settings


class MT5Service:
    """
    MT5 Service Class
    Like MQL5 class with static methods for trading operations
    """
    
    # =============================================================================
    # Class Variables (Like static variables in MQL5)
    # =============================================================================
    _active_connections: Dict = {}
    
    
    # =============================================================================
    # Connection Management
    # =============================================================================
    
    @classmethod
    async def connect_account(cls, account_id: str) -> Dict:
        """
        Connect to MT5 account via MetaAPI
        Like: bool ConnectToMT5(string accountId) in MQL5
        
        Args:
            account_id: MetaAPI account ID
            
        Returns:
            Dict containing connection info
            
        Raises:
            HTTPException: If connection fails
        """
        if not settings.METAAPI_TOKEN:
            raise HTTPException(
                status_code=503, 
                detail="MetaAPI token not configured"
            )
        
        try:
            # Initialize API
            api = MetaApi(token=settings.METAAPI_TOKEN)
            account = await api.metatrader_account_api.get_account(account_id)
            
            # Establish connection
            connection = account.get_rpc_connection()
            await connection.connect()
            await connection.wait_synchronized()
            
            # Get account information
            account_info = await connection.get_account_information()
            
            # Store connection in memory (like static variable in MQL5)
            cls._active_connections[account_id] = {
                "connection": connection,
                "account": account,
                "info": account_info
            }
            
            return {
                "status": "connected",
                "account_id": account_id,
                "account_info": account_info
            }
            
        except Exception as e:
            raise HTTPException(
                status_code=500, 
                detail=f"Failed to connect to MT5: {str(e)}"
            )
    
    
    @classmethod
    async def get_connection_status(cls) -> Dict:
        """
        Get current MT5 connection status
        Like: string GetConnectionStatus() in MQL5
        
        Returns:
            Dict containing connection status
        """
        if not cls._active_connections:
            return {
                "status": "disconnected", 
                "connected_accounts": []
            }
        
        return {
            "status": "connected",
            "connected_accounts": list(cls._active_connections.keys())
        }
    
    
    @classmethod
    async def get_account_info(cls, account_id: Optional[str] = None) -> Dict:
        """
        Retrieve account information from MetaApi
        Like: bool GetAccountInfo(string accountId, AccountInfo &info) in MQL5
        
        Args:
            account_id: Optional account ID, uses default if not provided
            
        Returns:
            Dict containing account information
            
        Raises:
            HTTPException: If retrieval fails
        """
        # Use default account if not specified
        if not account_id:
            account_id = settings.METAAPI_ACCOUNT_ID
        
        if not settings.METAAPI_TOKEN or not account_id:
            raise HTTPException(
                status_code=503, 
                detail="MetaApi credentials not configured"
            )
        
        try:
            # Initialize API
            api = MetaApi(token=settings.METAAPI_TOKEN)
            account = await api.metatrader_account_api.get_account(account_id)
            
            # Connect to account
            connection = account.get_rpc_connection()
            await connection.connect()
            await connection.wait_synchronized()
            
            # Get account information
            account_info = await connection.get_account_information()
            
            # Close connection (like closing handle in MQL5)
            await connection.close()
            
            return {
                "account_id": account_id, 
                "info": account_info
            }
            
        except Exception as e:
            raise HTTPException(
                status_code=500, 
                detail=f"Failed to fetch account info: {str(e)}"
            )
    
    
    @classmethod
    def get_active_connection(cls, account_id: str) -> Optional[Dict]:
        """
        Get active connection by account ID
        Like: Connection* GetConnection(string accountId) in MQL5
        
        Args:
            account_id: Account ID to look up
            
        Returns:
            Connection dict or None
        """
        return cls._active_connections.get(account_id)
    
    
    @classmethod
    async def disconnect_account(cls, account_id: str) -> bool:
        """
        Disconnect from MT5 account
        Like: bool Disconnect(string accountId) in MQL5
        
        Args:
            account_id: Account ID to disconnect
            
        Returns:
            True if successful
        """
        if account_id in cls._active_connections:
            try:
                connection = cls._active_connections[account_id]["connection"]
                await connection.close()
                del cls._active_connections[account_id]
                return True
            except Exception:
                return False
        return False
    
    
    @classmethod
    async def disconnect_all(cls) -> None:
        """
        Disconnect all active connections
        Like: void DisconnectAll() in MQL5
        """
        for account_id in list(cls._active_connections.keys()):
            await cls.disconnect_account(account_id)
