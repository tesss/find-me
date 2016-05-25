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
			addItem("Settings", :settings);
			addItem("Clear All", :clear);
			addItem("About", :about); // with connection status
		}
	}
	
	class MainMenuDelegate extends Ui.MenuInputDelegate {
		function onMenuItem(item){
			if(item == :types){
				pushTypesMenu();
			} else if(item == :addCurrent){
				var available = true;
				var info = null;
				if(dataStorage.currentLocation == null || dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_NOT_AVAILABLE){
					available = false;
					if(dataStorage.getInterval() >= 0){
						info = "Location not available";
					} else {
						info = "GPS disabled";
					}
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
			} else if(item == :batches){
				release();
				pushBatchesMenu();
			} else if(item == :settings){
				release();
				Ui.pushView(new SettingsPicker(), new SettingsPickerDelegate(), transition);
			} else if(item == :clear){
				release();
				dataStorage.clear();
				pushInfoView("Cleared", null, false);
			} else if(item == :about){
				Ui.pushView(new AboutView(), new AboutViewDelegate(), transition);
			}
		}
	}
}