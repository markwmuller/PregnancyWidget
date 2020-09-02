//Icon adapted from https://www.freevector.com/pregnancy-icon-set-21124

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application;

//from spacefem. Starts at 21 days. only valid to 21+44=65days
var riskArray_21dOut = [33, 32.9, 32.6, 32, 31.3, 30.3, 29.2, 28, 26.6, 25.2,
                        23.6, 22.1, 20.5, 18.9, 17.3, 15.8, 14.4, 13, 11.7, 10.5,
                        9.4, 8.4, 7.5, 6.6, 5.9, 5.3, 4.7, 4.3, 3.9, 3.5,
                        3.2, 3, 2.8, 2.6, 2.5, 2.4, 2.3, 2.2, 2.2, 2.1,
                        2.1, 2.1, 2.1, 2, ];
                        
// size table, indexed by wks: [mm, g] from http://perinatology.com/Reference/Fetal%20development.htm
// days are gestational, since LMP
var sizeTable = [
    [0, 0],
    [0, 0],
    [0, 0],
    [0, 0],
    [1, 0],
    [2, 0],
    [4, 0],
    [10, 1],
    [16, 5],
    [23, 15],
    [32, 35],
    [42, 45], 
    [53, 58], 
    [65, 73], 
    [79, 93],
    [164, 117],
    [183, 146], 
    [201, 181], 
    [220, 223], 
    [237, 273], 
    [255, 331], 
    [272, 399], 
    [288, 478], 
    [304, 568], 
    [320, 670], 
    [336, 785], 
    [351, 913], 
    [365, 1055], 
    [379, 1210], 
    [393, 1379], 
    [406, 1559], 
    [419, 1751], 
    [432, 1953], 
    [444, 2162], 
    [456, 2377], 
    [467, 2595], 
    [478, 2813], 
    [489, 3028], 
    [499, 3236], 
    [509, 3435], 
    [520, 3619], 
    [527, 3787], 
    ];
    
var heckWordTable = [
	"Heck!",
	"Baby!",
	"Oh my!",
	"Wowza!",
	"Oooofff!",
	"Uh-oh!",
	"Incoming!",
	]; 
	
//day, CDF value (see python script)
var cdfBornTable = [
      [246.42487046632124, 0.0],
      [267.6683937823834, 0.10108238090513785],
      [280.62176165803106, 0.5174984949848987],
      [298.2383419689119, 0.9999999966998467],
	]; 


class PregnancyWidgetView extends WatchUi.View {

	var shouldUpdate;

    function initialize() {
        shouldUpdate = true;
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));//draws a monkey
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        shouldUpdate = true;
    }
    
    function getHeckWord(){
        var ll = heckWordTable.size();
        var randInt = Time.now().value() % ll;
        return heckWordTable[randInt];
    }
    
    function getTimeToGoString(estDueDate, daysPregnant, daysToGo){
        if(Time.today().greaterThan(estDueDate)){
        	return "Overdue!";
        }
        var fractionComplete = (100*daysPregnant)/(40*7);

        var outStr = "TTG: ";
        var weeksToGo = daysToGo / 7;
        if (weeksToGo > 0){
            outStr += weeksToGo.format("%u")+"wk, ";
        }
        outStr +=  (daysToGo - weeksToGo*7).format("%u")+"d";

        outStr += "(" + fractionComplete.format("%u") + "%)\n";
        return outStr;
    }

    function getTimePregnantString(estDueDate, daysPregnant, daysToGo){
    	var outStr = "";
        var fractionComplete = (100*daysPregnant)/(40*7);
        
        //print time elapsed
        var weeksPregnant = daysPregnant / 7;
        if (weeksPregnant > 0){
            outStr += weeksPregnant.format("%u")+"wk, ";
        }
        outStr +=  (daysPregnant - weeksPregnant*7).format("%u")+"d ";
        outStr += "(" + fractionComplete.format("%u") + "%)\n";

        return outStr;
    }
    
    function getMiscarriageRiskString(daysPregnant){
        var outStr;

        var riskDayIndex = daysPregnant - 21;
        if(riskDayIndex >= riskArray_21dOut.size()){
            outStr = "P[surv]>=98%";
        } else if (riskDayIndex < 0){
        // no risk data
            outStr = "";
        } else {
            outStr = "P[surv]="+(100-riskArray_21dOut[riskDayIndex]).format("%.1f")+"%";
        }
        return outStr;
    }
    
    function getProbSpontaneousLabor(daysPregnant){
        //compute the approx. likelihood of spontaneous labor. 
        var outStr = "P[SL_1wk] ";
        var cdf_val_in1Wk = cdf_born_by(daysPregnant+7);
        var cdf_val_today = cdf_born_by(daysPregnant);
        var r;
        //bayes' rule
        if(cdf_val_today >= 1){
            //avoid divide by zero
            r = 1;
        } else {
            r = (cdf_val_in1Wk-cdf_val_today)/(1-cdf_val_today);
        }
        r *= 100;
        if(r < 0.01){
            outStr += "< 0.01% *";
        }else{
            outStr += "= "+r.format("%.1f")+"%";
        } 
    }
    

    // Update the view
    function onUpdate(dc) {
    	if(!shouldUpdate){
    		return;
        }
        shouldUpdate = false;
    	//things that should be settings:
    	var dueYear = 2021;
    	var dueMonth = 4;
    	var dueDay = 22; 
        var randomHeckWord = true; 
        var printTimeToGo = false; //else, print time pregnant (since LMP)
        var printMiscarriageRisk = true;  //else, probability of spontaneous labor
    	
        var options = {
            :year   => dueYear,
            :month  => dueMonth,
            :day    => dueDay,
            :hour   => 12,
            :min    => 0,
            :sec    => 0,
        };

        var estDueDate = Gregorian.moment(options);
        var info;

        info = Gregorian.info(estDueDate, Time.FORMAT_SHORT);

        var dueDateStr = Lang.format("$1$-$2$-$3$", [ info.year.format("%04u"), info.month.format("%02u"), info.day.format("%02u") ]);

        var infoString = "";

        //some useful numbers
        var timeToGo = estDueDate.subtract(Time.now());
        var timeToGoSec = timeToGo.value();
        var daysToGo = timeToGoSec / 86400;
        var daysPregnant = Time.today().value() - (estDueDate.value() - 40*7*24*60*60);
        daysPregnant /= (24*60*60); //from sec to days

        if(printTimeToGo){
            infoString += getTimeToGoString(estDueDate, daysPregnant, daysToGo);
        }else{
            infoString += getTimePregnantString(estDueDate, daysPregnant, daysToGo);
        }

        if(printMiscarriageRisk){
        	infoString += getMiscarriageRiskString(daysPregnant);
        }else{
        	infoString += getProbSpontaneousLabor(daysPregnant);
        }
        infoString += "\n";
        
        //Size info:
        var wksPregnant = daysPregnant / 7;
        var sizeStr;
        if(wksPregnant>=41){
            sizeStr = "Overdue!";
        } else if(wksPregnant<0){
            sizeStr = "Too early!";
        } else {
            var c = (daysPregnant - wksPregnant*7)/7.0;
            //interpolate wildly
            var l = sizeTable[wksPregnant][0] + (sizeTable[wksPregnant+1][0]-sizeTable[wksPregnant][0])*c;
            var m = sizeTable[wksPregnant][1] + (sizeTable[wksPregnant+1][1]-sizeTable[wksPregnant][1])*c;
            l = Math.round(l);
            m = Math.round(m);

            sizeStr = "";
            if(l < 1){
                sizeStr += "<1mm\n" ;
            } else {
                sizeStr += l.format("%u")+"mm\n" ;
            }
            if(m < 1){
                sizeStr += "<1g";
            } else {
                sizeStr += m.format("%u") + "g";
            }
        }
        infoString += sizeStr; 

        var dataString = "";
        if(randomHeckWord){
        	dataString += getHeckWord() + "\n";
        }
        dataString += "Due: " + dueDateStr;
        dataString += "\n";
        dataString += infoString;
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_BLACK );
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        dc.drawText( dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_TINY, dataString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function cdf_born_by(daysPreg) {
    //using data from this paper, with my own hand-baked piecewise linear approximation
    // The length of human pregnancy as calculated by ultrasonographic measurement of the fetal biparietal diameter
    // Dr H. Kieler O. Axelsson S. Nilsson U. Waldenströ
    	//read from our table, and interpolate wildly! 
    	if(daysPreg < cdfBornTable[0][0]){
            return 0.0;
        }
        //we'll need to look up --
        var i = 1;
        while(true){
        	if(i >= cdfBornTable.size()){
        		return 1;
            }
            if(cdfBornTable[i][0] > daysPreg){
                break;
            }
            i += 1;
        }
        var x0 = cdfBornTable[i-1][0];
        var x1 = cdfBornTable[i][0];
        var y0 = cdfBornTable[i-1][1];
        var y1 = cdfBornTable[i][1];
        return y0 + (daysPreg-x0)/(x1-x0)*(y1-y0);
    }
}
