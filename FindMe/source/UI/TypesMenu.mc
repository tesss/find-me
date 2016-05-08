using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class TypesMenu extends Ui.Menu {
		hidden var types;
		hidden var dataStorage;
		
		function initialize(_types, _dataStorage){
			types = _types;
			dataStorage = _dataStorage;
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
		hidden var dataStorage;
		
		hidden function getIndex(symbol){
			for(var i = 0; i < types.size(); i++){
				if(i == symbol){
					return i;
				}
			}
			return null;
		}
	
		function initialize(_types, _dataStorage){
			types = _types;
			dataStorage = _dataStorage;
		}
	
	    function onMenuItem(item) {
	    	var locations = types[getIndex(item)];
	    	var model = new LocationsViewModel(locations, dataStorage);
	    	Ui.pushView(new LocationView(model, dataStorage), new LocationDelegate(model), Ui.SLIDE_DOWN);
	    }
    }
}