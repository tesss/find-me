using Toybox.WatchUi as Ui;
using Data;

module UI{
	class LocationsMenu extends Ui.Menu {
		hidden var locations;
		
		function initialize(_locations){
			locations = _locations;
			setTitle("POI");
			for(var i = 0; i < locations.size(); i++){
				addItem(locations[i][Data.LOC_NAME], i);
			}
		}
	}
	
	class LocationsMenuDelegate extends Ui.MenuInputDelegate {
		hidden var locations;
		
		hidden function getIndex(symbol){
			for(var i = 0; i < locations.size(); i++){
				if(i == symbol){
					return i;
				}
			}
			return null;
		}
	
		function initialize(_locations){
			locations = _locations;
		}
	
	    function onMenuItem(item) {
	    	
	    }
    }
}