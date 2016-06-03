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
	    	model.get().sort();
	    	Ui.pushView(new LocationView(model.get()), new LocationDelegate(model), transition);
	    }
    }
}