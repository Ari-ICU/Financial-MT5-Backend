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
   string r = HttpGet("/account");
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
   if(lot <= 0) lot = DEFAULT_LOT_SIZE;

   string json = StringFormat(
      "{\"symbol\":\"%s\",\"volume\":%.2f,\"sl\":%.5f,\"tp\":%.5f,\"deviation\":%d}",
      TRADE_SYMBOL, lot, sl, tp, DEFAULT_DEVIATION
   );

   HttpPost("/buy", json);
}

void PlaceSell(double lot = 0.0, double sl = 0.0, double tp = 0.0)
{
   if(lot <= 0) lot = DEFAULT_LOT_SIZE;

   string json = StringFormat(
      "{\"symbol\":\"%s\",\"volume\":%.2f,\"sl\":%.5f,\"tp\":%.5f,\"deviation\":%d}",
      TRADE_SYMBOL, lot, sl, tp, DEFAULT_DEVIATION
   );

   HttpPost("/sell", json);
}

void CloseTicket(long ticket)
{
   if(ticket <= 0) { LogWarn("Invalid ticket", __FUNCTION__); return; }

   string json = StringFormat("{\"ticket\":%lld}", ticket);
   HttpPost("/close", json);
}

#endif