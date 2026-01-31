//+------------------------------------------------------------------+
//|                                          FastAPI_Actions.mqh     |
//|                     Trading & query functions                    |
//+------------------------------------------------------------------+
#property strict

#ifndef FASTAPI_ACTIONS_MQH
#define FASTAPI_ACTIONS_MQH

#include "FastAPI_Config.mqh"
#include "FastAPI_Http.mqh"
#include "FastAPI_Logger.mqh"

//+------------------------------------------------------------------+
//| Helper to extract Account ID from JSON string                    |
//+------------------------------------------------------------------+
long ExtractIdFromJson(string json)
{
   // Check for the "null" literal specifically
   if(StringFind(json, ":null") != -1) return 0;

   string key = "\"active_account_id\":\"";
   int startPos = StringFind(json, key);
   if(startPos == -1) return 0;

   startPos += StringLen(key);
   int endPos = StringFind(json, "\"", startPos);
   if(endPos == -1) return 0;

   string idStr = StringSubstr(json, startPos, endPos - startPos);
   return StringToInteger(idStr);
}

void TestConnection()
{
   string r = HttpGet("/mt5/account");
   if(r != "") LogInfo("Connection test OK - account info received", __FUNCTION__);
}

void GetSymbols()
{
   HttpGet("/symbols");
}

void GetRecentBars(int timeframe = 5, int count = 100)
{
   string ep = StringFormat("/bars?symbol=%s&timeframe=%d&count=%d", TRADE_SYMBOL, timeframe, count);
   HttpGet(ep);
}

void PlaceBuy(double lot = 0.0, double sl = 0.0, double tp = 0.0)
{
   datetime now = TimeCurrent();
   if(now - last_trade_time < MIN_SECONDS_BETWEEN_TRADES)
   {
      LogWarn("Buy skipped → too soon after last trade", __FUNCTION__);
      return;
   }

   if(lot <= 0) lot = DEFAULT_LOT_SIZE;
   
   string json = "{"
                 "\"symbol\":\""  + TRADE_SYMBOL              + "\","
                 "\"volume\":"    + DoubleToString(lot,2)     + ","
                 "\"sl\":"        + DoubleToString(sl,5)      + ","
                 "\"tp\":"        + DoubleToString(tp,5)      + ","
                 "\"deviation\":" + IntegerToString(DEFAULT_DEVIATION) +
                 "}";
   
   string resp = HttpWithRetry("/buy", true, json, 8);

   if(resp != "")
   {
      last_trade_time = now;
      LogInfo("Buy request sent → " + resp, __FUNCTION__);
   }
}

void PlaceSell(double lot = 0.0, double sl = 0.0, double tp = 0.0)
{
   datetime now = TimeCurrent();
   if(now - last_trade_time < MIN_SECONDS_BETWEEN_TRADES)
   {
      LogWarn("Sell skipped → too soon after last trade", __FUNCTION__);
      return;
   }

   if(lot <= 0) lot = DEFAULT_LOT_SIZE;

   string json = "{"
                 "\"symbol\":\""  + TRADE_SYMBOL              + "\"," 
                 "\"volume\":"    + DoubleToString(lot,2)     + ","
                 "\"sl\":"        + DoubleToString(sl,5)      + ","
                 "\"tp\":"        + DoubleToString(tp,5)      + ","
                 "\"deviation\":" + IntegerToString(DEFAULT_DEVIATION) +
                 "}";
   
   string resp = HttpWithRetry("/sell", true, json, 8);
   if(resp != "") last_trade_time = now;
}

void CloseTicket(long ticket)
{
   if(ticket <= 0) { LogWarn("Invalid ticket", __FUNCTION__); return; }

   string json = StringFormat("{\"ticket\":%lld}", ticket);
   HttpWithRetry("/close", true, json, 8);
}

void SendHeartbeat()
{
   long login      = AccountInfoInteger(ACCOUNT_LOGIN);
   string name     = AccountInfoString(ACCOUNT_NAME);
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   long leverage   = AccountInfoInteger(ACCOUNT_LEVERAGE); 
   double margin   = AccountInfoDouble(ACCOUNT_MARGIN_FREE); 
   string currency = AccountInfoString(ACCOUNT_CURRENCY);

   string json = StringFormat(
      "{\"login\":%lld,\"name\":\"%s\",\"balance\":%.2f,\"equity\":%.2f,\"free_margin\":%.2f,\"currency\":\"%s\",\"leverage\":%lld}",
      login, name, balance, equity, margin, currency, leverage
   );
   
   LogDebug("Sending heartbeat with leverage...", __FUNCTION__);
   HttpPost("/mt5/update", json);
}

void SyncWithUI()
{
   string response = HttpGet("/mt5/active-id");
   if(response == "") return;

   long ui_account_id = ExtractIdFromJson(response); 
   long local_id = AccountInfoInteger(ACCOUNT_LOGIN);

   // CRITICAL: Exit immediately if IDs don't match or UI is null (0)
   if(ui_account_id == 0 || ui_account_id != local_id)
   {
      // Using LogDebug to keep the Experts tab clean
      LogDebug("UI standing by for Account: " + IntegerToString(ui_account_id) + ". This terminal (Account: " + IntegerToString(local_id) + ") is suppressed.", __FUNCTION__);
      return; 
   }

   // Only proceed to heartbeat if the test above passed
   SendHeartbeat();
}
#endif