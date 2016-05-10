using Toybox.Graphics;
using Toybox.WatchUi as Ui;

module UI{
	class CoordinatesView extends Ui.View{
		hidden var str;
		
		function initialize(_str){
			str = _str;
		}
		
		function onUpdate(dc){
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.clear();
			var wc = dc.getWidth() / 2;
			var hc = dc.getHeight() / 2;
			var font = Graphics.FONT_TINY;
			dc.drawText(wc, hc - dc.getFontHeight(font), font, str, Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
	
	class CoordinatesDelegate extends Ui.BehaviorDelegate {
		function onBack(){
			Ui.popView(transition);
		}
		
		function onSelect(){
			Ui.popView(transition);
			Ui.popView(transition);
		}
	}
}