using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class AboutView extends Ui.View{
		function onUpdate(dc){
			dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
			dc.clear();
			dc.setColor(COLOR_PRIMARY, COLOR_BACKGROUND);
			var text = getText("Find % Me v.0.1", {});
			text.draw(dc);
		}
	}
	
	class AboutViewDelegate extends Ui.BehaviorDelegate {
		function onSelect(){
			Ui.popView(noTransition);
		}
	}
}