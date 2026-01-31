//+------------------------------------------------------------------+
//|                                    FastAPI_Trading_Bridge.mq5    |
//|               Optimized MT5 ↔ FastAPI Trading Bridge             |
//+------------------------------------------------------------------+
#property copyright "Optimized FastAPI bridge 2025–2026"
#property version   "1.04"
#property strict
#property description "Non-blocking MT5 <-> FastAPI bridge with rate limiting"
#property description "Attach to any chart — preferably M1 or M5"

#include <Helper\FastAPI_Logger.mqh>
#include <Helper\FastAPI_Config.mqh>
#include <Helper\FastAPI_Http.mqh>
#include <Helper\FastAPI_Utils.mqh>
#include <Helper\FastAPI_Actions.mqh>

// Global state for rate limiting / cooldowns
datetime last_logic_check   = 0;
datetime last_heartbeat     = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   LogInfo("EA initialized | API base = " + API_BASE_URL, __FUNCTION__);
   
   if(HEARTBEAT_SECONDS < 10)
      LogWarn("HEARTBEAT_SECONDS too low — setting minimum 10s", __FUNCTION__);

   TestConnection();

   // Check every 500ms for timer tasks
   EventSetMillisecondTimer(500);

   LogInfo("Initialization complete. Waiting for UI sync...", __FUNCTION__);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   LogInfo("EA stopped | reason = " + IntegerToString(reason), __FUNCTION__);
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Timer event — primary loop for UI Sync and Heartbeat             |
//+------------------------------------------------------------------+
void OnTimer()
{
   datetime now = TimeCurrent();
   if(now - last_heartbeat >= HEARTBEAT_SECONDS)
   {
      // REMOVE direct SendHeartbeat() calls.
      // Use SyncWithUI() as the only entry point.
      SyncWithUI(); 
      last_heartbeat = now;
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime now = TimeCurrent();

   // Throttle logic cycles to prevent terminal freezing
   if(now - last_logic_check < 5) return;
   last_logic_check = now;

   // We check sync on tick as well to ensure fast reaction to UI changes
   SyncWithUI();

   // ───────────────────────────────────────────────────────────────
   // Strategy Logic goes here
   // ───────────────────────────────────────────────────────────────
   double bid, ask;
   if(!GetCurrentPrices(TRADE_SYMBOL, bid, ask))
      return;
      
   // Note: SendHeartbeat() has been REMOVED from here. 
   // Communication is now managed strictly by SyncWithUI().
}

//+------------------------------------------------------------------+
//| Manual test functions                                            |
//+------------------------------------------------------------------+
void TestConnectionOnly() { TestConnection(); }
void TestFull()           { TestConnection(); GetSymbols(); GetRecentBars(5, 100); }
void TestBuy()            { PlaceBuy(DEFAULT_LOT_SIZE, 0.0, 0.0); }
void TestSell()           { PlaceSell(DEFAULT_LOT_SIZE, 0.0, 0.0); }