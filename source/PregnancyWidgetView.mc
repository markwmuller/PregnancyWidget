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


class PregnancyWidgetView extends WatchUi.View {

	var estDueDate;

    function initialize() {
        var options = {
            :year   => 2021,
            :month  => 4,
            :day    => 23,
            :hour   => 23
        };

        estDueDate = Gregorian.moment(options);


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
    }

    // Update the view
    function onUpdate(dc) {
// Saturday Feb 24th, 2018 12:12am
        var info;

        info = Gregorian.info(estDueDate, Time.FORMAT_SHORT);

        var dueDateStr = Lang.format("$1$-$2$-$3$", [ info.year.format("%04u"), info.month.format("%02u"), info.day.format("%02u") ]);

        var ttgString;

        var today = Time.today();
        
        if (today.greaterThan(estDueDate)){
        	ttgString = "Overdue!";
        } else {
            var timeToGo = estDueDate.subtract(Time.now());
            var timeToGoSec = timeToGo.value();
            var daysToGo = timeToGoSec / 86400;
            var weeksToGo = daysToGo / 7;
            ttgString  = "";
            if (weeksToGo > 0){
            	ttgString = ttgString + weeksToGo.format("%u")+"wk, ";
            }
            var fractionComplete = 100-(daysToGo*100)/(40*7);
            ttgString = ttgString + (daysToGo - weeksToGo*7).format("%u")+"d ";
            ttgString = ttgString + "(" + fractionComplete.format("%u") + "%)";
            
            var riskStr;
            var daysPregnant = (40*7-daysToGo);
            if(daysPregnant>44){
            	riskStr = "P[surv]>=98%";

            } else if (daysPregnant <21){
            // no risk data
                riskStr = "";
            } else {
            	riskStr = "P[surv]="+(100-riskArray_21dOut[daysPregnant-21]).format("%.1f")+"%";
            }
            ttgString = ttgString + "\n" + riskStr;
            
            //Size info:
            var wksPregnant = daysPregnant / 7;
            var sizeStr;
            if(wksPregnant>41){
            	sizeStr = "Overdue!";
            } else {
                var c = (daysPregnant - wksPregnant*7)/7.0;
                //interpolate wildly
                var l = sizeTable[wksPregnant][0] + (sizeTable[wksPregnant+1][0]-sizeTable[wksPregnant][0])*c;
                var m = sizeTable[wksPregnant][1] + (sizeTable[wksPregnant+1][1]-sizeTable[wksPregnant][1])*c;
                l = Math.round(l);
                m = Math.round(m);

                sizeStr = l.format("%u")+"mm\n" + m.format("%u") + "g";
            }
            ttgString = ttgString + "\n" + sizeStr; 
        }

        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_BLACK );
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        var string = "BABY!\nDue: " + dueDateStr;
        string = string + "\n";
        string = string + "TTG: " + ttgString;
        dc.drawText( dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_TINY, string, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
