using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class NewTypesMenu extends Ui.Menu {
		function initialize(){
			setTitle("Type");
			for(var i = 0; i < Data.DataStorage.TYPES.size(); i++){
				addItem(Data.DataStorage.TYPES[i], i);
			}
		}
	}
	
	class NewTypesMenuDelegate extends Ui.MenuInputDelegate {
		hidden var locationStr;
		hidden var name;
		hidden var format;
	
		function initialize(_locationStr, _name, _format){
			locationStr = _locationStr;
			name = _name;
			format = _format;
		}
		
		hidden function getIndex(symbol){
			for(var i = 0; i < Data.DataStorage.TYPES.size(); i++){
				if(i == symbol){
					return i;
				}
			}
			return null;
		}
	
	    function onMenuItem(item) {
	    	var index = getIndex(item);
	    	var loc = Position.parse(locationStr, format);
	    	var radians = loc.toRadians();
	    	var location = [null, name, radians[0], radians[1], index, null];
	    	var ids = dataStorage.addLocation(location);
	    	location[Data.LOC_ID] = ids.values()[0];
	    	var model = new TypesViewModel([[location]], false);
	    	model.index = 0;
	    	Ui.popView(noTransition);
	    	Ui.popView(noTransition);
	    	Ui.popView(noTransition);
	    	Ui.pushView(new LocationView(model.get()), new LocationDelegate(model), transition);
	    	pushInfoView("Location added", transition, false);
	    	
	    	// fix extra pops
	    	// add support for text input handler
	    }
    }
}