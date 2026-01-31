//+------------------------------------------------------------------+
//|                                            FastAPI_Utils.mqh     |
//+------------------------------------------------------------------+
#property strict

#ifndef FASTAPI_UTILS_MQH
#define FASTAPI_UTILS_MQH

#include "FastAPI_Config.mqh"
#include "FastAPI_Logger.mqh"


datetime last_request_time  = 0;
datetime last_trade_time    = 0;
datetime last_heartbeat     = 0;

// ── SafeFormat overloads (unique signatures only) ───────────────────────────
string SafeFormat(string fmt)
{
   return fmt;
}

string SafeFormat(string fmt, string arg1)
{
   return StringFormat(fmt, arg1);
}

string SafeFormat(string fmt, string arg1, string arg2)
{
   return StringFormat(fmt, arg1, arg2);
}

string SafeFormat(string fmt, string arg1, double arg2)
{
   return StringFormat(fmt, arg1, arg2);
}

string SafeFormat(string fmt, string arg1, double arg2, double arg3)
{
   return StringFormat(fmt, arg1, arg2, arg3);
}

string SafeFormat(string fmt, string arg1, double arg2, double arg3, int arg4)
{
   return StringFormat(fmt, arg1, arg2, arg3, arg4);
}

string SafeFormat(string fmt, string arg1, double arg2, double arg3, double arg4, int arg5)
{
   return StringFormat(fmt, arg1, arg2, arg3, arg4, arg5);
}


// For DateToApiString
string SafeFormat(string fmt, int y, int m, int d)
{
   return StringFormat(fmt, y, m, d);
}

// ── Position exists ──────────────────────────────────────────────────────────
bool PositionExists(long ticket)
{
   if(ticket <= 0) return false;
   int total = PositionsTotal();
   for(int i = total - 1; i >= 0; i--)
      if(PositionGetTicket(i) == ticket)
         return true;
   return false;
}

// ── Get bid/ask ──────────────────────────────────────────────────────────────
bool GetCurrentPrices(string symbol, double &bid, double &ask)
{
   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick))
   {
      LogError("Cannot get tick: " + symbol, __FUNCTION__);
      return false;
   }
   bid = tick.bid;
   ask = tick.ask;
   return (bid > 0 && ask > 0);
}

// ── Retry wrapper ────────────────────────────────────────────────────────────
string HttpWithRetry(string endpoint, bool is_post = false, string json_body = "", int custom_cooldown = -1)
{
   int cooldown_sec = (custom_cooldown >= 0) ? custom_cooldown : REQUEST_COOLDOWN_SEC;

   // Quick global rate limit check
   datetime now = TimeCurrent();
   if(now - last_request_time < cooldown_sec)
   {
      LogDebug("Request skipped - too soon (" + endpoint + ")", __FUNCTION__);
      return "";
   }

   int retries = 3;
   string resp = "";

   for(int i = 1; i <= retries; i++)
   {
      resp = is_post ? HttpPost(endpoint, json_body) : HttpGet(endpoint);

      if(resp != "") 
      {
         last_request_time = now;
         return resp;
      }

      LogWarn("Retry " + IntegerToString(i) + "/" + IntegerToString(retries) + " → " + endpoint, __FUNCTION__);
      Sleep(700 * i + 300);   // 1.0s → 1.7s → 2.4s backoff
   }

   LogError("All retries failed → " + endpoint, __FUNCTION__);
   return "";
}

// ── Date to YYYY-MM-DD ───────────────────────────────────────────────────────
string DateToApiString(datetime dt)
{
   MqlDateTime tm;
   TimeToStruct(dt, tm);
   return SafeFormat("%04d-%02d-%02d", tm.year, tm.mon, tm.day);
}

#endif