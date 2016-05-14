using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	var dataStorage;
	var transition;
	var noTransition;
	var screenType;
	var model;
	var firstLoad;
	var drawModel;
	
	const COLOR_BACKGROUND = 0x000000;
	const COLOR_PRIMARY = 0xFFFFFF;
	const COLOR_SECONDARY = 0xAAAAAA;
	const COLOR_LOWLIGHT = 0x555555;
	const COLOR_HIGHLIGHT = 0xFFAA00;
	
	function pushTypesMenu(){
		//release();
		if(model == null){
			var types = dataStorage.getTypesList();
			model = new TypesViewModel(types, true);
			types = null;
		}
		if(model.size() <= 1){
			pushInfoView("No locations", noTransition, false);
		} else {
			// delete/add/import into model
			Ui.pushView(new TypesMenu(model), new TypesMenuDelegate(model), noTransition);
		}
	}
	
	function release(){
		if(model != null){
			model.dispose();
			model = null;
			drawModel = null;
		}
	}

	class MainView extends Ui.View {
		function initialize(){
			screenType = getScreenType();
			transition = Ui.SLIDE_DOWN;
			if(screenType == :square && dataStorage.deviceSettings.inputButtons & System.BUTTON_INPUT_UP == 0){
				transition = Ui.SLIDE_RIGHT;
			}
			noTransition = Ui.SLIDE_IMMEDIATE;
			firstLoad = true;
			
			Ui.pushView(new MainMenu(), new MainMenuDelegate(), noTransition);
			pushTypesMenu();
		}
		
		function onShow(){
			if(firstLoad){
				firstLoad = false;
			} else {
				if(dataStorage.session != null && dataStorage.session.isRecording()){
					firstLoad = true;
					Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(true), noTransition);
				} else {
					Ui.popView(noTransition);
				}
			}
		}
	}
	
	function getScreenType(){
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