//+------------------------------------------------------------------+
//|                                             FastAPI_Config.mqh   |
//|                     Configuration & Inputs                       |
//+------------------------------------------------------------------+
#property strict

#ifndef FASTAPI_CONFIG_MQH
#define FASTAPI_CONFIG_MQH

input string   API_BASE_URL       = "http://127.0.0.1:8001";   // Must be allowed in MT5 → Expert Advisors
input int      HTTP_TIMEOUT_MS    = 8001;
input string   TRADE_SYMBOL       = "EURUSD";
input double   DEFAULT_LOT_SIZE   = 0.01;
input int      DEFAULT_DEVIATION  = 30;
input bool     ENABLE_CHART_COMMENT = true;
input bool     ENABLE_DEBUG_LOGS   = true;  

input int      HEARTBEAT_SECONDS     = 60;     
input int      MIN_SECONDS_BETWEEN_TRADES = 15; 
input int      REQUEST_COOLDOWN_SEC      = 4;   

// ===== MULTI ACCOUNT SUPPORT =====
string TERMINAL_ID;    // auto-filled at runtime

#endif
