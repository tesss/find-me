using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Data;
using _;

module UI{
	class LocationView extends Ui.View{
		hidden var dataStorage;
		hidden var locations;
		hidden var index;
	
		function initialize(_dataStorage, _locations, _index){
			dataStorage = _dataStorage;
			locations = _locations;
			index = _index;
		}
	
		function onUpdate(dc){
			var location = locations[index];
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			dc.clear();
			var wc = dc.getWidth() / 2;
			var hc = dc.getHeight() / 2;
			dc.drawText(wc, hc - 30, Graphics.FONT_LARGE, location[Data.LOC_NAME], Graphics.TEXT_JUSTIFY_CENTER);
			dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
			dc.drawText(wc, hc + 10, Graphics.FONT_SMALL, Data.DataStorage.TYPES[location[Data.LOC_TYPE]], Graphics.TEXT_JUSTIFY_CENTER);
			if(dataStorage.currentLocation != null){
				var distance = Data.distance(location[Data.LOC_LAT], location[Data.LOC_LON], dataStorage.currentLocation[Data.LAT], dataStorage.currentLocation[Data.LON]);
				dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
				dc.drawText(wc, hc + 40, Graphics.FONT_MEDIUM, distance, Graphics.TEXT_JUSTIFY_CENTER);
			}
		}
	}
}