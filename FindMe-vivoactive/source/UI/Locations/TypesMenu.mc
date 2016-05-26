using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class TypesMenu extends Ui.Menu {
		hidden var model;
		
		function initialize(_model){
			model = _model;
			setTitle("Types");
			for(var i = 0; i < model.size(); i++){
				addItem(model.getTypeName(i), i);
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