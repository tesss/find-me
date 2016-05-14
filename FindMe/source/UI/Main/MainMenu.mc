using Toybox.WatchUi as Ui;
using Toybox.Position;

module UI{
	class MainMenu extends Ui.Menu {
		function initialize(){
			setTitle("Find Me");
			addItem("Locations", :types);
			addItem("Add Current", :addCurrent);
			addItem("Add Coordinates", :add);
			addItem("Find", :find);
			addItem("Batches", :batches);
			
			addItem("Sorting", :sortby);
			addItem("Distance Filter", :distance);
			addItem("GPS Interval", :interval);
			addItem("GEO Format", :format);
			addItem("Activity Type", :format);
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
			} else if(item == :addCurrent){
				var available = true;
				var info = null;
				if(dataStorage.currentLocation == null || dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_NOT_AVAILABLE){
					available = false;
					info = "Location not available";
				} else if(dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_LAST_KNOWN){
					info = "Using last known position";
				} else if(dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_POOR){
					info = "Poor signal quality";
				} else if(dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_USABLE){
					//info = "Usable signal quality";
				} else if(dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_GOOD){
					//info = "Good signal quality";
				}
				if(available){
					release();
					var format = dataStorage.getFormat();
					pushNameView(new Position.Location({
						:latitude => dataStorage.currentLocation[Data.LAT],
						:longitude => dataStorage.currentLocation[Data.LON],
						:format => :radians}).toGeoString(format), format, false);
				}
				if(info != null){
					pushInfoView(info, null, false);
				}
			} else if(item == :add){
				release();
				var format = dataStorage.getFormat();
				Ui.pushView(new LocationPicker(format), new LocationPickerDelegate(format), transition);
			} else if(item == :find){
				release();
				pushFindView();
			}
		}
	}
}