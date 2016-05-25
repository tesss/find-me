using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class MainView extends Ui.View {
		function initialize(){
			screenType = getScreenType();
			transition = Ui.SLIDE_IMMEDIATE;
			openMainMenu = true;
			openTypesMenu = true;
		}
		
		function onShow(){
			release();
			if(openMainMenu){
				openMainMenu = false;
				pushMainMenu();
				if(openTypesMenu){
					pushTypesMenu();
					openTypesMenu = false;
				}
			} else {
				if(dataStorage.session != null && dataStorage.session.isRecording()){
					openMainMenu = true;
					Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(true), transition);
				} else {
					Ui.popView(transition);
				}
			}
		}
	}
	
	function getScreenType(){
		var screenShape = System.getDeviceSettings().screenShape;
		if(screenShape == System.SCREEN_SHAPE_ROUND){
			return :round;
		}
		if(screenShape == System.SCREEN_SHAPE_RECTANGLE){
			if(screenWidth > screenHeight){
				return :square;
			} else {
				return :tall;
			}
		}
		if(screenShape == System.SCREEN_SHAPE_SEMI_ROUND){
			return :semiround;
		}
		return null;
	}
}