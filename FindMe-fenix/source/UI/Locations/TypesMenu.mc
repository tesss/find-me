using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class TypesMenu extends Ui.Menu {
		function initialize(_model){
			setTitle("Types");
			for(var i = 0; i < _model.size(); i++){
				addItem(_model.getTypeName(i), i);
			}
		}
	}
	
	class TypesMenuDelegate extends Ui.MenuInputDelegate {
		hidden var model;
	
		function initialize(_model){
			model = _model;
		}
	
	    function onMenuItem(item) {
	    	model.index = getMenuIndex(item, model.size());
	    	var locations = model.get();
	    	locations.sort();
	    	locations.index = 0;
	    	Ui.pushView(new LocationView(locations), new LocationDelegate(model), transition);
	    }
    }
}