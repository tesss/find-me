using Toybox.WatchUi as Ui;
using Toybox.Position;

module UI{
	class MainMenu extends Ui.Menu {
		function initialize(){
			setTitle("Find Me");
			addItem("Locations", :types);
			addItem("Add Current", :addCurrent);
			addItem("Add Coordinates", :add);
			addItem("Settings", :settings);
			addItem("Reset", :reset);
			addItem("About", :about); // with connection status
		}
	}
	
	class MainMenuDelegate extends Ui.MenuInputDelegate {
		function onMenuItem(item){
			if(item == :types){
				popMainMenu();
				pushTypesMenu();
			} else if(item == :addCurrent){
				if(pushIfInsufficientSpace()){
					return;
				}
				var available = true;
				var info = null;
				if(dataStorage.currentLocation == null || dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_NOT_AVAILABLE){
					available = false;
					info = "Not available";
				} else if(dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_LAST_KNOWN){
					info = "Last position";
				} else if(dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_POOR){
					info = "Poor signal";
				}
				if(available){
					release();
					var format = dataStorage.getFormat();
					popMainMenu();
					pushNameView(new Position.Location({
						:latitude => dataStorage.currentLocation[Data.LAT],
						:longitude => dataStorage.currentLocation[Data.LON],
						:format => :radians}).toGeoString(format), format, defLocationName());
				}
				if(info != null){
					pushInfoView(info, false);
				}
			} else if(item == :add){
				if(pushIfInsufficientSpace()){
					return;
				}
				release();
				var format = dataStorage.getFormat();
				popMainMenu();
				Ui.pushView(new LocationPicker(format), new LocationPickerDelegate(format), transition);
			} else if(item == :settings){
				release();
				popMainMenu();
				Ui.pushView(new SettingsPicker(), new SettingsPickerDelegate(), transition);
			} else if(item == :reset){
				release();
				dataStorage.reset();
				pushInfoView("Reset done", false);
			} else if(item == :about){
				popMainMenu();
				Ui.pushView(new AboutView(), new AboutViewDelegate(), transition);
			}
		}
	}
}