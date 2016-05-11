using Toybox.WatchUi as Ui;

module UI{
	class MainMenu extends Ui.Menu {
		hidden var dataStorage;
		
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
			setTitle("Find Me");
			addItem("Locations", :types);
			addItem("Add", :add);
			addItem("Find", :find);
			addItem("Batches", :batches);
			
			addItem("Sorting", :sortby);
			addItem("Distance Filter", :distance);
			addItem("GPS interval", :interval);
			addItem("GEO format", :format);
			addItem("Activity type", :format);
			addItem("Clear All", :clear);
			addItem("About", :about); // with connection status
		}
	}
	
	class MainMenuDelegate extends Ui.MenuInputDelegate {
		hidden var dataStorage;
		
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
		}
		
		function onMenuItem(item){
			if(item == :types){
				pushTypesMenu(dataStorage);
			} else if(item == :add) {
				Ui.pushView(new LocationPicker(dataStorage.getFormat()), new LocationPickerDelegate(), transition);
			}
		}
	}
}