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

string HttpPost(string endpoint, string json)
{
   char data[], result[];
   string resp_headers;

   StringToCharArray(json, data);
   ArrayResize(data, StringLen(json));   // avoid null terminator issues

   string url = API_BASE_URL + endpoint;
   string headers = "Content-Type: application/json\r\n";

   LogDebug("POST → " + url + " | JSON: " + StringSubstr(json,0,120), __FUNCTION__);

   ResetLastError();
   int code = WebRequest("POST", url, headers, NULL, HTTP_TIMEOUT_MS,
                         data, ArraySize(data), result, resp_headers);

   string resp = CharArrayToString(result,0,-1,CP_UTF8);

   if(code == -1 || code >= 400)
   {
      int err = GetLastError();
      LogError("POST failed | " + endpoint + " | HTTP=" + IntegerToString(code) + " | Err=" + IntegerToString(err), __FUNCTION__);
      LogError("Sent JSON: " + json, __FUNCTION__);
      LogError("Response: " + resp, __FUNCTION__);
      return "";
   }

   LogInfo("POST OK | " + endpoint + " | HTTP " + IntegerToString(code), __FUNCTION__);
   LogDebug("Response: " + StringSubstr(resp,0,180), __FUNCTION__);

   return resp;
}

#endif