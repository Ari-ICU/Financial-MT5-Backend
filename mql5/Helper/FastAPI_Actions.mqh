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
//| Extract active_account_id from JSON                              |
//+------------------------------------------------------------------+
long ExtractActiveAccountId(string json)
{
   if(StringFind(json, "\"active_account_id\":null") != -1) 
      return 0;
   
   if(StringFind(json, "\"active_account_id\":") == -1) 
      return 0;

   string search = "\"active_account_id\":\"";
   int pos = StringFind(json, search);
   if(pos == -1) return 0;

   pos += StringLen(search);
   int end = StringFind(json, "\"", pos);
   if(end == -1) return 0;

   string id_str = StringSubstr(json, pos, end - pos);
   long id = StringToInteger(id_str);
   
   return (id > 0) ? id : 0;
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

//+------------------------------------------------------------------+
//| Only send heartbeat if this terminal is the selected one        |
//+------------------------------------------------------------------+
void SyncWithUI()
{
   string resp = HttpGet("/mt5/active-id");
   if(resp == "" || StringLen(resp) < 10)
   {
      LogDebug("No valid response from /mt5/active-id", __FUNCTION__);
      return;
   }

   long requested_id = ExtractActiveAccountId(resp);
   
   if(requested_id == 0)
   {
      LogDebug("No account currently selected in UI", __FUNCTION__);
      return;
   }

   long my_login = AccountInfoInteger(ACCOUNT_LOGIN);
   
   if(requested_id != my_login)
   {
      // Optional: log only every ~30 seconds to reduce spam
      static datetime last_log = 0;
      if(TimeCurrent() - last_log > 30)
      {
         LogDebug(StringFormat("UI selected %lld | this terminal is %lld → silent mode", 
                              requested_id, my_login), __FUNCTION__);
         last_log = TimeCurrent();
      }
      return;
   }

   // ── Only if IDs match ──
   LogInfo("This terminal is selected in UI → sending heartbeat", __FUNCTION__);
   SendHeartbeat();
}

#endif