using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	var transition;
	var noTransition;
	var screenType;
	var model;
	
	const COLOR_BACKGROUND = 0x000000;
	const COLOR_PRIMARY = 0xFFFFFF;
	const COLOR_SECONDARY = 0xAAAAAA;
	const COLOR_LOWLIGHT = 0x555555;
	const COLOR_HIGHLIGHT = 0xFFAA00;
	
	function pushTypesMenu(dataStorage){
		release();
		var types = dataStorage.getTypesList();
		if(types.size() <= 1){
			// show add locations
			Ui.pushView(new InfoView("No locations"), new InfoDelegate(false), noTransition);
		} else {
			model = new TypesViewModel(types, dataStorage);
			Ui.pushView(new TypesMenu(model), new TypesMenuDelegate(model), noTransition);
		}
		types = null;
	}
	
	function release(){
		if(model != null){
			model.dispose();
			model = null;
		}
	}

	class MainView extends Ui.View {
		hidden var dataStorage;
		hidden var firstLoad;
	
		function initialize(_dataStorage){
			dataStorage = _dataStorage;
		
			screenType = getScreenType(dataStorage);
			transition = Ui.SLIDE_DOWN;
			if(screenType == :square && dataStorage.deviceSettings.inputButtons & System.BUTTON_INPUT_UP == 0){
				transition = Ui.SLIDE_RIGHT;
			}
			noTransition = Ui.SLIDE_IMMEDIATE;
			firstLoad = true;
			
			Ui.pushView(new MainMenu(dataStorage), new MainMenuDelegate(dataStorage), noTransition);
			pushTypesMenu(dataStorage);
		}
		
		function onShow(){
			if(firstLoad){
				firstLoad = false;
			} else {
				if(dataStorage.session != null && dataStorage.session.isRecording()){
					firstLoad = true;
					Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(dataStorage, true), noTransition);
				} else {
					Ui.popView(noTransition);
				}
			}
		}
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