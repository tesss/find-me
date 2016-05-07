using Toybox.WatchUi as Ui;
using Data;

module UI{
	class TypesMenu extends Ui.Menu {
		hidden var types;
		
		function initialize(_types){
			types = _types;
			setTitle("Types");
			for(var i = 0; i < types.size(); i++){
				if(i == 0){
	     			addItem("All", i);
		    	} else {
		    		var key = types[i][0][Data.LOC_TYPE];
		    		var type = Data.DataStorage.TYPES[key];
		    		addItem(type, i);
		    	}
			}
		}
	}
	
	class TypesMenuDelegate extends Ui.MenuInputDelegate {
		hidden var types;
		
		hidden function getIndex(symbol){
			for(var i = 0; i < types.size(); i++){
				if(i == symbol){
					return i;
				}
			}
			return null;
		}
	
		function initialize(_types){
			types = _types;
		}
	
	    function onMenuItem(item) {
	    	var locations = types[getIndex(item)];
	    	Ui.pushView( new LocationsMenu(locations), new LocationsMenuDelegate(locations), Ui.SLIDE_DOWN );
	    }
    }
}