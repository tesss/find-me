using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Lang;

module UI{
	class InfoView extends Ui.View{
		hidden var str;
		hidden var error;
		
		function initialize(_str, _error){
			str = _str;
			error = _error;
		}
		
		function onUpdate(dc){
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.clear();
			var w = dc.getWidth();
			var h = dc.getHeight();
			var wc = w / 2;
			var hc = h / 2;
			var h6 = h / 6;
			var font = Graphics.FONT_SMALL;
			var y = hc - dc.getFontHeight(font)/2;
			dc.drawText(wc, y, font, str, Graphics.TEXT_JUSTIFY_CENTER);
			
			if(error){
				dc.setColor(Graphics.COLOR_RED, COLOR_PRIMARY);
			} else {
				dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			}
			dc.drawRectangle(0, h6 * 4 + 3, w, h6 - 3);
			y = h6 * 4.5 - dc.getFontHeight(font)/2;
			dc.setColor(COLOR_PRIMARY, COLOR_LOWLIGHT);
			dc.drawText(wc, y, font, "  OK  ", Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
	
	class InfoDelegate extends Ui.BehaviorDelegate {
		hidden var pop;
		
		function initialize(_pop){
			pop = _pop;
		}
	
		function onBack(){
			if(pop){
				Ui.popView(transition);
			}
		}
		
		function onSelect(){
			Ui.popView(transition);
			if(pop){
				Ui.popView(transition);
			}
		}
	}
}