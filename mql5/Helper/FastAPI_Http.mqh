//+------------------------------------------------------------------+
//|                                               FastAPI_Http.mqh   |
//|                     HTTP communication layer                     |
//+------------------------------------------------------------------+
#property strict

#ifndef FASTAPI_HTTP_MQH
#define FASTAPI_HTTP_MQH

#include "FastAPI_Config.mqh"
#include "FastAPI_Logger.mqh"

string HttpGet(string endpoint)
{
   char post[]; ArrayResize(post,0);
   char result[];
   string headers;

   string url = API_BASE_URL + endpoint;

   LogDebug("GET → " + url, __FUNCTION__);

   ResetLastError();
   int code = WebRequest("GET", url, NULL, NULL, HTTP_TIMEOUT_MS, post, 0, result, headers);

   string resp = CharArrayToString(result,0,-1,CP_UTF8);

   if(code == -1)
   {
      int err = GetLastError();
      LogError("GET failed | URL=" + url + " | Err=" + IntegerToString(err) + " | HTTP=" + IntegerToString(code), __FUNCTION__);
      return "";
   }

   LogInfo("GET OK | " + endpoint + " | HTTP " + IntegerToString(code) + " | len=" + IntegerToString(StringLen(resp)), __FUNCTION__);
   LogDebug("Response: " + StringSubstr(resp,0,180), __FUNCTION__);

   return resp;
}

//+------------------------------------------------------------------+
//| Fully Fixed HttpPost for macOS / Direct FastAPI Bridge           |
//+------------------------------------------------------------------+
string HttpPost(string endpoint, string json)
{
   if(StringLen(json) == 0) return "";

   char data[], result[];
   string resp_headers;
   
   // Convert string to UTF-8 byte array
   int len = StringToCharArray(json, data, 0, WHOLE_ARRAY, CP_UTF8);
   
   // CRITICAL FIX: Resize to remove the null terminator byte '\0'
   // FastAPI's json parser will fail if this byte is included
   if(len > 0) ArrayResize(data, len - 1); 

   string url = API_BASE_URL + endpoint;
   string headers = "Content-Type: application/json\r\n";

   ResetLastError();
   // Explicitly pass ArraySize(data) to ensure the correct payload length
   int code = WebRequest("POST", url, headers, HTTP_TIMEOUT_MS, data, result, resp_headers);

   if(code == -1)
   {
      LogError("WebRequest Error: " + (string)GetLastError(), __FUNCTION__);
      return "";
   }

   string resp = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   
   if(code >= 400)
   {
      LogError(StringFormat("Server rejected request: %d | Response: %s", code, resp), __FUNCTION__);
      return "";
   }

   return resp;
}
#endif