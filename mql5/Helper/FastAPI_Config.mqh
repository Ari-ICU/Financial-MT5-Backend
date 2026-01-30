//+------------------------------------------------------------------+
//|                                             FastAPI_Config.mqh   |
//|                     Configuration & Inputs                       |
//+------------------------------------------------------------------+
#property strict

#ifndef FASTAPI_CONFIG_MQH
#define FASTAPI_CONFIG_MQH

input string   API_BASE_URL       = "http://127.0.0.1:8000";   // Must be allowed in MT5 → Expert Advisors
input int      HTTP_TIMEOUT_MS    = 8000;
input string   TRADE_SYMBOL       = "EURUSD";
input double   DEFAULT_LOT_SIZE   = 0.01;
input int      DEFAULT_DEVIATION  = 30;
input bool     ENABLE_CHART_COMMENT = true;
input bool     ENABLE_DEBUG_LOGS   = true;   // ← toggle verbose output

#endif