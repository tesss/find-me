using Toybox.WatchUi as Ui;

module UI{
	class MainView extends Ui.View {
		hidden var dataStorage;
	
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
			var types = dataStorage.getTypesList();
			openTypesMenu(types);
		}
		
	    function openTypesMenu(types) {
	    	// show info if no elements
	        Ui.pushView(new TypesMenu(types, dataStorage), new TypesMenuDelegate(types, dataStorage), Ui.SLIDE_DOWN);
	    }
	}
}