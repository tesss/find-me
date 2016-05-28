using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Data;
using _;

module UI {
	class AboutView extends Ui.View{
		function initialize(){
		}
		
		function onUpdate(dc){
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.clear();
			dc.setColor(COLOR_PRIMARY, COLOR_BACKGROUND);
			var text = getText("FindMe v.0.1", {});
			text.draw(dc); 
		}
	}
	
	class AboutViewDelegate extends Ui.BehaviorDelegate {
		function onSelect(){
			Ui.popView(transition);
		}
	}
}