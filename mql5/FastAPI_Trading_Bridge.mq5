//+------------------------------------------------------------------+
//|                                    FastAPI_Trading_Bridge.mq5    |
//|               Optimized MT5 ↔ FastAPI Trading Bridge             |
//+------------------------------------------------------------------+
#property copyright "Optimized FastAPI bridge 2025–2026"
#property version   "1.03"
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
   LogInfo("Make sure FastAPI server is running and URL is allowed in MT5 → Tools → Options → Expert Advisors", __FUNCTION__);

   if(HEARTBEAT_SECONDS < 10)
   {
      LogWarn("HEARTBEAT_SECONDS too low — setting minimum 10s", __FUNCTION__);
   }

   TestConnection();

   // Optional: use timer for periodic lightweight checks (~every 500 ms)
   EventSetMillisecondTimer(500);

   LogInfo("Initialization complete. Waiting for ticks / timer...", __FUNCTION__);
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
//| Timer event — used for periodic non-urgent tasks                 |
//+------------------------------------------------------------------+
void OnTimer()
{
   static int counter = 0;
   counter++;

   datetime now = TimeCurrent();

   // Heartbeat every HEARTBEAT_SECONDS
   if(now - last_heartbeat >= HEARTBEAT_SECONDS)
   {
      SendHeartbeat();
      last_heartbeat = now;
   }

   // Example: other periodic queries (uncomment as needed)
   // if(counter % 20 == 0) GetAccountInfo();    // every ~10 seconds
   // if(counter % 60 == 0) GetOpenPositions();  // every ~30 seconds
}

//+------------------------------------------------------------------+
//| Expert tick function — MUST stay very fast!                      |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime now = TimeCurrent();

   // Throttle logic cycles — adjust 3–15 seconds depending on strategy
   if(now - last_logic_check < 5) return;
   last_logic_check = now;

   // ───────────────────────────────────────────────────────────────
   //   Put your trading decision logic here
   //   → Do NOT make HTTP calls directly in OnTick()
   //   → Call PlaceBuy() / PlaceSell() only when you really want to trade
   // ───────────────────────────────────────────────────────────────

   double bid, ask;
   if(!GetCurrentPrices(TRADE_SYMBOL, bid, ask))
      return;

   // ── Example placeholder logic (replace with your strategy) ───────
   /*
   double ma_fast = iMA(TRADE_SYMBOL, PERIOD_CURRENT, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ma_slow = iMA(TRADE_SYMBOL, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE, 0);

   if(ma_fast > ma_slow && PositionsTotal() == 0)
   {
      PlaceBuy(DEFAULT_LOT_SIZE, bid - 150*_Point, bid + 300*_Point);
   }
   else if(ma_fast < ma_slow && PositionsTotal() == 0)
   {
      PlaceSell(DEFAULT_LOT_SIZE, ask + 150*_Point, ask - 300*_Point);
   }
   */

   // For manual / testing only — remove or comment in production
   // static int counter = 0;
   // if(counter++ % 120 == 0) PlaceBuy(DEFAULT_LOT_SIZE, 0, 0);
}

//+------------------------------------------------------------------+
//| Manual test functions — can be called from scripts / buttons     |
//+------------------------------------------------------------------+
void TestConnectionOnly()
{
   TestConnection();
}

void TestFull()
{
   TestConnection();
   GetSymbols();
   GetRecentBars(5, 100);
   // PlaceBuy(DEFAULT_LOT_SIZE, 0.0, 0.0);   // uncomment only when ready!
}

void TestBuy()
{
   PlaceBuy(DEFAULT_LOT_SIZE, 0.0, 0.0);
}

void TestSell()
{
   PlaceSell(DEFAULT_LOT_SIZE, 0.0, 0.0);
}

//+------------------------------------------------------------------+