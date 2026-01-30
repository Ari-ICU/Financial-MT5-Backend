//+------------------------------------------------------------------+
//|                                            FastAPI_Logger.mqh    |
//|                     Simple but powerful logger                   |
//+------------------------------------------------------------------+
#property strict

#ifndef FASTAPI_LOGGER_MQH
#define FASTAPI_LOGGER_MQH

#include "FastAPI_Config.mqh"

enum LogLevel { LOG_INFO, LOG_WARN, LOG_ERROR, LOG_DEBUG };

void Log(LogLevel level, string message, string func = "")
{
   string prefix = "";
   color clr = clrNONE;

   switch(level)
   {
      case LOG_INFO:   prefix = "[INFO] ";   clr = clrDodgerBlue;  break;
      case LOG_WARN:   prefix = "[WARN] ";   clr = clrOrange;      break;
      case LOG_ERROR:  prefix = "[ERROR] ";  clr = clrRed;         break;
      case LOG_DEBUG:  prefix = "[DEBUG] ";  clr = clrGray;        break;
   }

   string full = prefix;
   if(func != "") full += func + " → ";
   full += message;

   Print(full);

   if(ENABLE_CHART_COMMENT && level <= LOG_WARN)
      Comment(full);

   // Optional: write to file later (easy to add)
}

void LogInfo(string msg, string func="")   { if(true) Log(LOG_INFO, msg, func); }
void LogWarn(string msg, string func="")    { Log(LOG_WARN, msg, func); }
void LogError(string msg, string func="")   { Log(LOG_ERROR, msg, func); }
void LogDebug(string msg, string func="")   { if(ENABLE_DEBUG_LOGS) Log(LOG_DEBUG, msg, func); }

#endif