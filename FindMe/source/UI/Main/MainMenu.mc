using Toybox.WatchUi as Ui;

module UI{
	class MainMenu extends Ui.Menu {
		function initialize(){
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
		function initialize(){
		}
		
		function onMenuItem(item){
			if(item == :types){
				pushTypesMenu();
			} else if(item == :add) {
				release();
				var format = dataStorage.getFormat();
				Ui.pushView(new LocationPicker(format), new LocationPickerDelegate(format), transition);
			}
		}
	}
}