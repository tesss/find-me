using Toybox.WatchUi as Ui;

module UI{
	const TRANSITION = 3;

	class MainView extends Ui.View {
		hidden var dataStorage;
	
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
			var types = dataStorage.getTypesList();
			openTypesMenu(types);
		}
		
	    function openTypesMenu(types) {
	    	// show info if no elements
	        Ui.pushView(new TypesMenu(types, dataStorage), new TypesMenuDelegate(types, dataStorage), TRANSITION);
	    }
	}
	
	class MainDelegate extends Ui.BehaviorDelegate {
		hidden var dataStorage;
		
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
		}
		
		function onMenu(){
			Ui.pushView(new MainMenu(dataStorage), new MainMenuDelegate(dataStorage), TRANSITION);
		}
	}
}