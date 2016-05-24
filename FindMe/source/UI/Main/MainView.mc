using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class MainView extends Ui.View {
		function initialize(){
			screenType = getScreenType();
			transition = Ui.SLIDE_IMMEDIATE;
			firstLoad = true;
			pushMainMenu();
			pushTypesMenu();
		}
		
		function onShow(){
			if(firstLoad){
				firstLoad = false;
			} else {
				if(dataStorage.session != null && dataStorage.session.isRecording()){
					firstLoad = true;
					Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(true), transition);
				} else {
					Ui.popView(transition);
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