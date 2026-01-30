//+------------------------------------------------------------------+
//|                                    FastAPI_Trading_Bridge.mq5    |
//|               Main EA – attach to chart                          |
//+------------------------------------------------------------------+
#property copyright "Debug-friendly FastAPI bridge"
#property version   "1.02"
#property strict
#property description "Modular MT5 <-> FastAPI bridge. Check Experts tab."

#include "Include\\FastAPI_Config.mqh"
#include "Include\\FastAPI_Logger.mqh"
#include "Include\\FastAPI_Http.mqh"
#include "Include\\FastAPI_Actions.mqh"

//+------------------------------------------------------------------+
int OnInit()
{
   LogInfo("EA started | API = " + API_BASE_URL, __FUNCTION__);
   LogInfo("Make sure FastAPI runs and URL is allowed in MT5 options", __FUNCTION__);

   TestConnection();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   LogInfo("EA stopped", __FUNCTION__);
}

//+------------------------------------------------------------------+
void OnTick()
{
   // For automatic logic → add here later
   // Example (uncomment for test):
   // static datetime last=0; if(TimeCurrent()-last>300){ last=TimeCurrent(); PlaceBuy(); }
}

// --- Manual test calls (you can call from scripts or add buttons later) ---
void TestAll()
{
   TestConnection();
   GetSymbols();
   GetRecentBars();
   // PlaceBuy();   // uncomment only when ready
}