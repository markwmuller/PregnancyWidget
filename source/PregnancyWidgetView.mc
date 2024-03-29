//Icon adapted from https://www.freevector.com/pregnancy-icon-set-21124

using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

// size table, indexed by wks: [age (wks), length (mm), mass (g)] from https://www.babycenter.com/pregnancy/your-body/growth-chart-fetal-length-and-weight-week-by-week_1290794
// wks are gestational, since LMP
// Extrapolated data below 8 wks
var sizeTable = [
			[0, 0, 0],
			[1, 0, 0],
			[2, 0, 0],
			[3, 0, 0],
			[4, 0, 0],
			[5, 1, 0],
			[6, 7, 0],
			[7, 11, 0],
			[8, 16, 1],
			[9, 23, 2],
			[10, 31, 4],
			[11, 41, 7],
			[12, 54, 14],
			[13, 74, 23],
			[14, 87, 43],
			[15, 101, 70],
			[16, 116, 100],
			[17, 130, 140],
			[18, 142, 190],
			[19, 153, 240],
			[20, 256, 300],
			[21, 267, 360],
			[22, 278, 430],
			[23, 289, 501],
			[24, 300, 600],
			[25, 346, 660],
			[26, 356, 760],
			[27, 366, 875],
			[28, 376, 1005],
			[29, 386, 1153],
			[30, 399, 1319],
			[31, 411, 1502],
			[32, 424, 1702],
			[33, 437, 1918],
			[34, 450, 2146],
			[35, 462, 2383],
			[36, 474, 2622],
			[37, 486, 2859],
			[38, 498, 3083],
			[39, 507, 3288],
			[40, 512, 3462],
			[41, 517, 3597],
			[42, 515, 3685],
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
	
class PregnancyWidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        WatchUi.requestUpdate();
    }
    
    function getHeckWord(){
        var ll = heckWordTable.size();
        var randInt = Time.now().value() % ll;
        return heckWordTable[randInt];
    }
    
    function getPercentageComplete(secondsPregnant){
        return (100.0*secondsPregnant)/(40*7*24*60*60);
    }
    
    function getTimeToGoString(estDueDate, secondsPregnant, daysToGo){
        if(Time.today().greaterThan(estDueDate)){
        	return "Overdue!";
        }
        var fractionComplete = getPercentageComplete(secondsPregnant);

        var outStr = "TTG: ";
        var weeksToGo = daysToGo / 7;
        if (weeksToGo > 0){
            outStr += weeksToGo.format("%u")+"wk, ";
        }
        outStr +=  (daysToGo - weeksToGo*7).format("%u")+"d";

        outStr += "(" + fractionComplete.format("%u") + "%)\n";
        return outStr;
    }

    function getTimePregnantString(estDueDate, secondsPregnant, daysToGo){
    	var outStr = "";
        var fractionComplete = getPercentageComplete(secondsPregnant);
        
        //print time elapsed
        var daysPregnant = secondsPregnant / (24*60*60);
        var weeksPregnant = daysPregnant / 7;
        if (weeksPregnant > 0){
            outStr += weeksPregnant.format("%u")+"wk, ";
        }
        outStr +=  (daysPregnant - weeksPregnant*7).format("%u")+"d ";
        outStr += "(" + fractionComplete.format("%u") + "%)\n";

        return outStr;
    }
    
    function getSizeString(secondsPregnant, useSillyUnits){
        //Size info:
        var wksPregnant = secondsPregnant / (7*24*60*60);
        var sizeStr;
        if(wksPregnant>=41){
            sizeStr = "Overdue!";
        } else if(wksPregnant<0){
            sizeStr = "Too early!";
        } else {
            var c = (secondsPregnant - wksPregnant*7*24*60*60)/(7.0*24*60*60);//fraction of week completed, should be in [0,1)
            //interpolate wildly
            var l = sizeTable[wksPregnant][1] + (sizeTable[wksPregnant+1][1]-sizeTable[wksPregnant][1])*c;
            var m = sizeTable[wksPregnant][2] + (sizeTable[wksPregnant+1][2]-sizeTable[wksPregnant][2])*c;
            if(!useSillyUnits){
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
            }else{
            	l = l / 25.4; //mm to inches
            	m = m / 28.34952; //g to oz

				sizeStr = "";
				if(l < 0.04){
					sizeStr += "<0.04in\n" ;
                }else if(l < 1){
					sizeStr += l.format("%.2f")+"in\n" ;
				} else {
					sizeStr += l.format("%.1f")+"in\n" ;
				}
				if(m < 0.04){
					sizeStr += "<0.04oz";
				} else if(m < 1) {
					sizeStr += m.format("%.2f") + "oz";
				} else if(m < 16) {
                    //less than 1lb
					sizeStr += m.format("%.2f") + "oz";
				} else {
                    //16 oz in 1 lb, it turns out...
                    var lb = Math.floor(m).toNumber() / 16;
                    var oz = m - lb*16;
					sizeStr += lb.format("%u") + "lb, " + oz.format("%.1f") + "oz";
				}
            }
        }
     	return sizeStr; 
    }
    
    function getAngleModulo360(in){
        //note -- rounds to 1 degree
    	var tmp = in.toNumber();
    	while(tmp < 0){
    		tmp += 360;
        }
    	while(tmp >= 360){
    		tmp -= 360;
        }
    	return tmp;
    }
    
    

    // Update the view
    function onUpdate(dc) {
        //read our settings:
    	var dueYear = Application.Properties.getValue("dueDateYear");
    	var dueMonth = Application.Properties.getValue("dueDateMonth");
    	var dueDay = Application.Properties.getValue("dueDateDay");

        var titleMode = Application.Properties.getValue("titleMode"); 
        var customTitle = Application.Properties.getValue("customTitle"); 

        var printTimeToGo = Application.Properties.getValue("printTimeToGo"); //else, print time pregnant (since LMP)
        
        var accentColor = Application.Properties.getValue("accentColor"); 

        var useSillyUnits = Application.Properties.getValue("useSillyUnits"); 
        
        if(dueYear == 0){
        	//settings aren't valid -- tell user to update
			dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_BLACK );
			dc.clear();
			dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
			dc.drawText( dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_TINY, "Please enter\ndue date\nin settings", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
			return;
        }
    	 
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

        //some useful numbers
        var timeToGo = estDueDate.subtract(Time.now());
        var timeToGoSec = timeToGo.value();
        var daysToGo = timeToGoSec / 86400;
        var secondsPregnant = Time.now().value() - (estDueDate.value() - 40*7*24*60*60);
        
        var dataString = "";
        if(titleMode == 1){
    		//random heck word
        	dataString += getHeckWord() + "\n";
        }else if(titleMode == 2){
        	//custom string
        	dataString += customTitle + "\n";
        }else{
			//levae blank
        }
        dataString += "Due: " + dueDateStr;
        dataString += "\n";

		//get text to print
        if(printTimeToGo){
            dataString += getTimeToGoString(estDueDate, secondsPregnant, daysToGo);
        }else{
            dataString += getTimePregnantString(estDueDate, secondsPregnant, daysToGo);
        }

        dataString += getSizeString(secondsPregnant, useSillyUnits);

        // clear the display
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_BLACK );
        dc.clear();
		//draw progress arc -- 
        var arcRadius;
        if(dc.getWidth()>dc.getHeight()){
        	arcRadius = dc.getHeight()/2;
        }else{
        	arcRadius = dc.getWidth()/2;
        }
        arcRadius -= 6;

		var startAngle = 85;
		var rangeAngle = 350;
        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT );
        dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, arcRadius, Toybox.Graphics.ARC_CLOCKWISE, startAngle, getAngleModulo360(startAngle - rangeAngle));
//        System.println(getAngleModulo360(startAngle - rangeAngle).format("%d"));

        dc.setPenWidth(6);
        if(accentColor == 2){
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT );
        } else if(accentColor == 3){
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT );
        } else if(accentColor == 4){
            dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT );
        } else if(accentColor == 5){
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT );
        } else if(accentColor == 6){
            dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT );
        }else{//default
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT );
        }
        var percentCompleteCapped = getPercentageComplete(secondsPregnant);
        if(percentCompleteCapped > 100){
            percentCompleteCapped = 100;
        }
        dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, arcRadius, Toybox.Graphics.ARC_CLOCKWISE, startAngle, getAngleModulo360(startAngle - percentCompleteCapped/100.0*rangeAngle));
        
		//draw text
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        dc.drawText( dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_TINY, dataString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
