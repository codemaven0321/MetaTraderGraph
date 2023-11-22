//+------------------------------------------------------------------+
//|                                  Timeframes Top Bottom Lines.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

class TimeframesLines {

  private:
    string yesterdayCloseLabel, todayOpenLabel, yesterdayHighLabel;
    color lineColor;
    int fontSize;
    double yesterdayCloseRate, todayOpenRate, yesterdayHighRate;
    ENUM_LINE_STYLE lineStyle;
    void createLabels(void);
    void createLine(string objLabel);
    void putLabels( string label, double price);
 
  public:
    TimeframesLines(double _yesterdayCloseRate, double _todayOpenRate, double _yesterdayHighRate, color _linesColor, int _fontSize);
    ~TimeframesLines(void);
    void moveLabels(void);
 };

TimeframesLines::TimeframesLines(double _yesterdayCloseRate, double _todayOpenRate, double _yesterdayHighRate, color _linesColor, int _fontSize) {
  this.lineColor = _linesColor;
  this.fontSize = _fontSize;
  this.yesterdayCloseRate = _yesterdayCloseRate;
  this.todayOpenRate = _todayOpenRate;
  this.yesterdayHighRate = _yesterdayHighRate;

  this.createLabels();
  this.createLine(this.yesterdayCloseLabel);
  this.createLine(this.yesterdayHighLabel);
  this.createLine(this.todayOpenLabel);
};

TimeframesLines::~TimeframesLines() {
  ObjectDelete(0, this.yesterdayCloseLabel);
  ObjectDelete(0, this.yesterdayHighLabel);
  ObjectDelete(0, this.todayOpenLabel);
}

void TimeframesLines::createLabels(void) {
  datetime currentDatetime = TimeCurrent();
  string todayMonthDayString = TimeToString(currentDatetime,  TIME_DATE);  // format: MM-DD
  datetime yesterdayDatetime = currentDatetime - PeriodSeconds(PERIOD_D1);  // subtract 1 day
  string yesterdayMonthDayString = TimeToString(yesterdayDatetime, TIME_DATE);  // format: MM-DD

  this.yesterdayCloseLabel = StringFormat("Yesterday(%s)'s Close", yesterdayMonthDayString);
  this.yesterdayHighLabel = StringFormat("Yesterday(%s)'s High", yesterdayMonthDayString);
  this.todayOpenLabel = StringFormat("Today(%s)'s Open", todayMonthDayString);
};

void TimeframesLines::createLine(string objLabel) {
   string objLine = objLabel+"_line";
   ObjectCreate(0, objLine, OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, objLine, OBJPROP_COLOR, this.lineColor);
   ObjectSetInteger(0, objLine, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, objLine, OBJPROP_WIDTH, 2);
   ObjectSetString(0, objLine, OBJPROP_TOOLTIP, objLabel);
   
   ObjectSetInteger(0, objLine, OBJPROP_SELECTABLE, true);
   ObjectSetString(0, objLine, OBJPROP_TEXT, objLabel);
   ObjectSetInteger(0, objLine, OBJPROP_YDISTANCE, 10); 
   
   
   string obj_text = objLabel+"_text";
   ObjectSetString(0,obj_text,OBJPROP_FONT,"Arial"); 
   ObjectSetInteger(0,obj_text,OBJPROP_FONTSIZE,20); 
   ObjectSetInteger(0,obj_text,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, obj_text, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0,obj_text,OBJPROP_ZORDER,1000); 
   
   string obj_label = objLabel+"_label";
   ObjectCreate(0,obj_label,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,obj_label,OBJPROP_XDISTANCE,10); 
   ObjectSetInteger(0,obj_label,OBJPROP_CORNER,CORNER_RIGHT_LOWER); 
   ObjectSetString(0,obj_label,OBJPROP_TEXT, objLabel); 
   ObjectSetString(0,obj_label,OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0,obj_label,OBJPROP_FONTSIZE,this.fontSize); 
   ObjectSetInteger(0,obj_label,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER); 
   ObjectSetInteger(0,obj_label,OBJPROP_COLOR,this.lineColor); 
   ObjectSetInteger(0,obj_label,OBJPROP_SELECTABLE,false); 
 
  
  
/*  ObjectCreate(0, objLabel, OBJ_HLINE, 0, 0, 0);
  ObjectSetInteger(0, objLabel, OBJPROP_COLOR, this.lineColor);
  ObjectSetString(0, objLabel, OBJPROP_FONT, "Arial");
  ObjectSetInteger(0, objLabel, OBJPROP_FONTSIZE, 30);
  ObjectSetString(0, objLabel, OBJPROP_TEXT, "1231222222222222222222222222222222222222222222223111111111111111111111");
  ObjectSetString(0, objLabel, OBJPROP_TOOLTIP, objLabel);
  ObjectSetString(0, objLabel, OBJPROP_LEVELTEXT, "level text here"); 
  ObjectSetInteger(0, objLabel, OBJPROP_WIDTH, 2);
  ObjectSetInteger(0, objLabel, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0,objLabel,OBJPROP_ANCHOR, ANCHOR_LEFT);
  ObjectSetInteger(0,objLabel,OBJPROP_CORNER, CORNER_RIGHT_UPPER);
 */
  //ChartRedraw(0);
};

void TimeframesLines::putLabels( string label, double price){
   double chartMinPrice = ChartGetDouble(0, CHART_PRICE_MIN);
   double chartMaxPrice = ChartGetDouble(0, CHART_PRICE_MAX);
   
   int chartHeight = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int yPosition = (int)(chartHeight * (price - chartMinPrice) / (chartMaxPrice - chartMinPrice)) + this.fontSize*2;
   PrintFormat( "price : %f", price);
   PrintFormat( "chartMinPrice : %f", chartMinPrice);
   PrintFormat( "chartMaxPrice : %f", chartMaxPrice);
   PrintFormat( "chartHeight : %d", chartHeight);
   PrintFormat( "%s : %d", label, yPosition);
   if( yPosition < chartHeight){
      ObjectSetInteger(0,label,OBJPROP_YDISTANCE, yPosition);
      
   }
}

void TimeframesLines::moveLabels() {
  ObjectMove(0, this.yesterdayCloseLabel+"_line", 0, TimeCurrent(), this.yesterdayCloseRate);
  ObjectMove(0, this.yesterdayHighLabel+"_line", 0, TimeCurrent(), this.yesterdayHighRate);
  ObjectMove(0, this.todayOpenLabel+"_line", 0, TimeCurrent(), this.todayOpenRate);
  
  this.putLabels(this.yesterdayCloseLabel+"_label", this.yesterdayCloseRate);
  this.putLabels(this.yesterdayHighLabel+"_label", this.yesterdayHighRate);
  this.putLabels(this.todayOpenLabel+"_label", this.todayOpenRate);
  
  ChartRedraw(0);
};
