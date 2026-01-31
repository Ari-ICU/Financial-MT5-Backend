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

   // Ensure the string format is clean with no extra spaces or characters at the end
   string json = StringFormat(
      "{\"login\":%lld,\"name\":\"%s\",\"balance\":%.2f,\"equity\":%.2f,\"free_margin\":%.2f,\"currency\":\"%s\",\"leverage\":%lld}",
      login, name, balance, equity, margin, currency, leverage
   );

   LogDebug("Sending heartbeat...", __FUNCTION__);
   HttpPost("/mt5/update", json);
}

//+------------------------------------------------------------------+
//| Only send heartbeat if this terminal is the selected one         |
//| UPDATED: Instant sync logic                                      |
//+------------------------------------------------------------------+
void SyncWithUI()
{
   string response = HttpGet("/mt5/active-id");
   if(response == "" || StringLen(response) < 10)
   {
      LogDebug("No valid response from /mt5/active-id", __FUNCTION__);
      return;
   }

   // 1. Extract the active ID from the JSON response
   string requested_str = "";
   int pos = StringFind(response, "\"active_account_id\":\"");
   if(pos != -1)
   {
      pos += StringLen("\"active_account_id\":\"");
      int end = StringFind(response, "\"", pos);
      if(end != -1)
         requested_str = StringSubstr(response, pos, end - pos);
   }

   // 2. Handle null or empty active ID
   if(requested_str == "" || requested_str == "null")
   {
      LogDebug("No active account selected in UI", __FUNCTION__);
      return;
   }

   // 3. Compare with current terminal login
   string my_login_str = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));

   if(requested_str == my_login_str)
   {
      // SUCCESS: This terminal is the one the user wants to see.
      // We call SendHeartbeat() immediately to push data to the backend.
      LogInfo(StringFormat("Match found (ID: %s) -> Pushing data to UI...", my_login_str), __FUNCTION__);
      SendHeartbeat(); 
   }
   else 
   {
      // SILENT MODE: Another terminal is active. 
      // We only log this once every 30 seconds to avoid flooding the terminal logs.
      static datetime lastLog = 0;
      datetime now = TimeCurrent();
      if(now - lastLog >= 30)
      {
         LogWarn(StringFormat("Idle: UI wants %s, but I am %s", requested_str, my_login_str), __FUNCTION__);
         lastLog = now;
      }
   }
}

#endif