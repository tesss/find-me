using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Data;
using _;

module UI {
	class AboutView extends Ui.View{
		function initialize(){
		}
		
		function fontPadding(font){
			return Graphics.getFontHeight(font)/2;
		}
		
		function onUpdate(dc){
			var h = dc.getHeight();
			var wc = dc.getWidth()/2;
			var hc = h/2;
			var d = 15;
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.clear();
			dc.setColor(COLOR_SECONDARY, COLOR_PRIMARY);
			dc.drawText(wc, hc - fontPadding(Graphics.FONT_NUMBER_THAI_HOT), Graphics.FONT_NUMBER_THAI_HOT, Data.VERSION, Graphics.TEXT_JUSTIFY_CENTER);
			dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(wc, hc - fontPadding(Graphics.FONT_LARGE), Graphics.FONT_LARGE, "FindMe", Graphics.TEXT_JUSTIFY_CENTER);
			dc.setColor(COLOR_LOWLIGHT, Graphics.COLOR_TRANSPARENT);
			dc.drawText(wc, d - fontPadding(Graphics.FONT_XTINY), Graphics.FONT_XTINY, "(c) Andriy Babets", Graphics.TEXT_JUSTIFY_CENTER);
			dc.drawText(wc, h - d - fontPadding(Graphics.FONT_XTINY), Graphics.FONT_XTINY, "STORAGE: " + dataStorage.locCount + "/" + Data.LOC_MAX_COUNT, Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
	
	class AboutViewDelegate extends Ui.BehaviorDelegate {
		function onSelect(){
			Ui.popView(transition);
		}
	}
}