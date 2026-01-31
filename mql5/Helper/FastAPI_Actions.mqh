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

   // More efficient JSON construction
   string json = "{"
                 "\"symbol\":\""  + TRADE_SYMBOL              + "\","
                 "\"volume\":"    + DoubleToString(lot,2)     + ","
                 "\"sl\":"        + DoubleToString(sl,5)      + ","
                 "\"tp\":"        + DoubleToString(tp,5)      + ","
                 "\"deviation\":" + IntegerToString(DEFAULT_DEVIATION) +
                 "}";

   string resp = HttpWithRetry("/buy", true, json, 8);   // longer cooldown for trades

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

   // Correctly format the JSON string with the "login" field
   string json = StringFormat(
      "{\"login\":%lld,\"name\":\"%s\",\"balance\":%.2f,\"equity\":%.2f}",
      login, name, balance, equity
   );
   
   HttpPost("/mt5/update", json);
}
#endif