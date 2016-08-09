using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class NewTypesMenu extends Ui.Menu {
		function initialize(){
			setTitle("Type");
			for(var i = 0; i < dataStorage.TYPES.size(); i++){
				addItem(dataStorage.TYPES[i], i);
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
	
	    function onMenuItem(item) {
	    	var index = getMenuIndex(item, dataStorage.TYPES.size());
	    	var loc = Position.parse(locationStr, format);
	    	var radians = loc.toRadians();
	    	var location = [null, name, radians[0], radians[1], index, null];
	    	var ids = dataStorage.addLocation(location);
	    	location[Data.LOC_ID] = ids[0];
	    	var model = new TypesViewModel([[location]], false);
	    	popMainMenu();
	    	Ui.pushView(new LocationView(model.get()), new LocationDelegate(model), transition);
	    }
    }
}