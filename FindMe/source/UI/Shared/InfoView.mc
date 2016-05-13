using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Lang;

module UI{
	function pushInfoView(_str, _transition, _pop, _exit){
		if(_transition == null){
			_transition = transition;
		}
		_pop = _pop == null || _pop instanceof Lang.Method || _pop;
		_exit = _exit == true;
		Ui.pushView(new InfoView(_str), new InfoDelegate(_pop, _exit), _transition);
	}

	class InfoView extends Ui.View{
		hidden var str;
		
		function initialize(_str){
			str = _str;
		}
		
		function onUpdate(dc){
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.clear();
			var w = dc.getWidth();
			var h = dc.getHeight();
			var wc = w / 2;
			var hc = h / 2;
			var h6 = h / 6;
			var font = Graphics.FONT_TINY;
			var y = hc - dc.getFontHeight(font)/2;
			dc.drawText(wc, y, font, str, Graphics.TEXT_JUSTIFY_CENTER);
			
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.drawRectangle(0, h6 * 4, w, h6);
			y = h6 * 4.5 - dc.getFontHeight(font)/2;
			dc.setColor(COLOR_PRIMARY, COLOR_LOWLIGHT);
			dc.drawText(wc, y, font, "  OK  ", Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
	
	class InfoDelegate extends Ui.BehaviorDelegate {
		hidden var pop;
		hidden var exit;
		
		function initialize(_pop, _exit){
			pop = _pop;
			exit = _exit;
		}
	
		function onBack(){
			if(exit){
				System.exit();
				return;
			}
			if(pop){
				Ui.popView(noTransition);
			}
		}
		
		function onSelect(){
			if(exit){
				System.exit();
				return;
			}
			Ui.popView(noTransition);
			if(pop){
				Ui.popView(noTransition);
			}
		}
	}
}