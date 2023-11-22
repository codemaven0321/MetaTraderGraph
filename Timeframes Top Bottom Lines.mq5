//+------------------------------------------------------------------+
//|                                  Timeframes Top Bottom Lines.mq5 |
//|                                Copyright 2019, Leonardo Sposina. |
//|           https://www.mql5.com/en/users/leonardo_splinter/seller |
//+------------------------------------------------------------------+

#include "TimeframesLines.mqh"

#property indicator_plots 0

// Session Start & End time
input string sessionStartTime = "08:00";  // Default session start time
input string sessionEndTime = "16:00";    // Default session end time
input int labelFontSize = 10;  // Default font size for labels
input color lineColor = clrBlue;  // Default color for lines

TimeframesLines* lines;

datetime yesterdayStart;
datetime yesterdayEnd;

int OnInit() {
   string symbol = _Symbol;
   ENUM_TIMEFRAMES timeframe = PERIOD_D1;
   
   // Convert the input time strings to datetime values
   datetime todayStart = StringToTime(sessionStartTime);
   datetime todayEnd = StringToTime(sessionEndTime);

   
   MqlDateTime mqlDT4YesterdayStart;
   TimeToStruct(todayEnd, mqlDT4YesterdayStart); 
   mqlDT4YesterdayStart.day--;
   yesterdayStart = StructToTime( mqlDT4YesterdayStart);
   
   MqlDateTime mqlDT4YesterdayEnd;
   TimeToStruct(todayEnd,mqlDT4YesterdayEnd); 
   mqlDT4YesterdayEnd.day--;
   yesterdayEnd = StructToTime( mqlDT4YesterdayEnd);
   
   double yesterdayCloseRate = 0;
   double todayOpenRate = 0;
   double yesterdayHighRate = 0;
   
   MqlRates rates4TodayOpen[];
   ArraySetAsSeries(rates4TodayOpen, true);  // set the array as series
      
   int copiedBars = CopyRates(_Symbol, _Period, todayStart, 1, rates4TodayOpen);  // copy 1 bar with the specific datetime
   
   if (copiedBars > 0) {
       todayOpenRate = rates4TodayOpen[0].open;
       PrintFormat("Today's Open Price at %s: %.*f", TimeToString( todayStart, TIME_DATE|TIME_MINUTES), _Digits, todayOpenRate);
   } else {
       Print("No bars found with the specific datetime");
   }
   
   MqlRates rates4YesterdayClose[];
   ArraySetAsSeries(rates4YesterdayClose, true);  // set the array as series
   copiedBars = CopyRates(_Symbol, _Period, yesterdayEnd, 1, rates4YesterdayClose);  // copy 1 bar with the specific datetime
   
   if (copiedBars > 0) {
       yesterdayCloseRate = rates4YesterdayClose[0].close;
       PrintFormat("Yesterday's Close Price at %s: %.*f", TimeToString(yesterdayEnd, TIME_DATE|TIME_MINUTES), _Digits, yesterdayCloseRate);
   } else {
       Print("No bars found with the specific datetime");
   }
   
   MqlRates ratesForYesterdaysHigh[];
   ArraySetAsSeries(ratesForYesterdaysHigh, true);  // set the array as series
   
   copiedBars = CopyRates(_Symbol, _Period, yesterdayStart, (yesterdayEnd - yesterdayStart) / PeriodSeconds(_Period) + 1, ratesForYesterdaysHigh);  // copy bars within the specified time range
   
   if (copiedBars > 0) {
       yesterdayHighRate = ratesForYesterdaysHigh[0].high;
       for (int i = 1; i < copiedBars; i++) {
           if (ratesForYesterdaysHigh[i].high > yesterdayHighRate) {
               yesterdayHighRate = ratesForYesterdaysHigh[i].high;
           }
       }
       PrintFormat("Highest high between %s and %s: %.*f", TimeToString(yesterdayStart, TIME_DATE|TIME_MINUTES), TimeToString(yesterdayEnd, TIME_DATE|TIME_MINUTES), _Digits, yesterdayHighRate);
   } else {
       Print("No bars found within the specified time range");
   }
   
   lines = new TimeframesLines( yesterdayCloseRate, todayOpenRate, yesterdayHighRate, lineColor, labelFontSize);
   
   ObjectCreate(0, "yesterdayStart", OBJ_VLINE, 0, yesterdayStart, 0);
   ObjectSetInteger(0, "yesterdayStart", OBJPROP_COLOR, clrRosyBrown);

   ObjectCreate(0, "yesterdayEnd", OBJ_VLINE, 0, yesterdayEnd, 0);
   ObjectSetInteger(0, "yesterdayEnd", OBJPROP_COLOR, clrRosyBrown);
   
   ObjectCreate(0, "todayStart", OBJ_VLINE, 0, todayStart, 0);
   ObjectSetInteger(0, "todayStart", OBJPROP_COLOR, clrRosyBrown);
   
   ObjectCreate(0, "todayEnd", OBJ_VLINE, 0, todayEnd, 0);
   ObjectSetInteger(0, "todayEnd", OBJPROP_COLOR, clrRosyBrown);
  
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   delete lines;

   ChartRedraw();
}

int OnCalculate(
  const int rates_total,
  const int prev_calculated,
  const int begin,
  const double &price[]
) {
   lines.moveLabels();

  return(rates_total);
}
