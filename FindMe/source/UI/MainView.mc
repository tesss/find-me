using Toybox.WatchUi as Ui;

module UI{
	var transition;
	var screenType;

	class MainView extends Ui.View {
		hidden var dataStorage;
	
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
		
			screenType = getScreenType(dataStorage);
			transition = Ui.SLIDE_DOWN;
			if(screenType == :square && dataStorage.deviceSettings.inputButtons & System.BUTTON_INPUT_UP == 0){
				transition = Ui.SLIDE_RIGHT;
			}
			Ui.pushView(new MainMenu(dataStorage), new MainMenuDelegate(dataStorage), transition);
			// show info if no elements
			var types = dataStorage.getTypesList();
			Ui.pushView(new TypesMenu(types, dataStorage), new TypesMenuDelegate(types, dataStorage), transition);
		}
	}
	
	class MainDelegate extends Ui.BehaviorDelegate {
		hidden var dataStorage;
		
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
		}
		
		// check onExit
	}
	
	function getScreenType(dataStorage){
		if(dataStorage.deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND){
			return :round;
		}
		if(dataStorage.deviceSettings.screenShape == System.SCREEN_SHAPE_RECTANGLE){
			if(dataStorage.deviceSettings.screenWidth > dataStorage.deviceSettings.screenHeight){
				return :square;
			} else {
				return :tall;
			}
		}
		if(dataStorage.deviceSettings.screenShape == System.SCREEN_SHAPE_SEMI_ROUND){
			return :semiround;
		}
		return null;
	}
}