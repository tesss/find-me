using Toybox.WatchUi as Ui;

module UI{
	class MainMenu extends Ui.Menu {
		hidden var dataStorage;
		
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
			setTitle("find^me");
			addItem("Locations", :types);
			addItem("Add", :add);
			addItem("Find", :find);
			addItem("Batches", :batches);
			addItem("Sorting", :sortby);
			addItem("Distance Filter", :distance);
			addItem("GPS interval", :interval);
			addItem("About", :about);
		}
	}
	
	class MainMenuDelegate extends Ui.MenuInputDelegate {
		hidden var dataStorage;
		
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
		}
		
		function onMenuItem(item){
			if(item == :types){
				var types = dataStorage.getTypesList();
				Ui.pushView(new TypesMenu(types, dataStorage), new TypesMenuDelegate(types, dataStorage), transition);
			} else {
			}
		}
	}
}