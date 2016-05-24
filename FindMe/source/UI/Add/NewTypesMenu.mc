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
		hidden var fromTextPicker;
		hidden var pop;
	
		function initialize(_locationStr, _name, _format, _fromTextPicker, _pop){
			locationStr = _locationStr;
			name = _name;
			format = _format;
			fromTextPicker = _fromTextPicker;
			pop = _pop;
		}
	
	    function onMenuItem(item) {
	    	var index = getMenuIndex(item, Data.DataStorage.TYPES.size());
	    	var loc = Position.parse(locationStr, format);
	    	var radians = loc.toRadians();
	    	var location = [null, name, radians[0], radians[1], index, null];
	    	var ids = dataStorage.addLocation(location);
	    	location[Data.LOC_ID] = ids.values()[0];
	    	var model = new TypesViewModel([[location]], false);
	    	if(pop){
	    		Ui.popView(transition);
	    	}
	    	if(!fromTextPicker){
	    		Ui.popView(transition);
	    	}
	    	pushMainMenu();
	    	Ui.pushView(new LocationView(model.get()), new LocationDelegate(model), transition);
	    	// add support for text input handler
	    }
    }
}