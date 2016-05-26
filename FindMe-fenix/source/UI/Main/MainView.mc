using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class MainView extends Ui.View {
		function initialize(){
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
}