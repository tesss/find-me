using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class MainView extends Ui.View {
		function initialize(){
			transition = Ui.SLIDE_IMMEDIATE;
			keepMainView = false;
			openMainMenu = false;
			openTypesMenu = true;
			openBatchesMenu = false;
		}
		
		function onShow(){
			if(keepMainView){
				keepMainView = false;
				openMainMenu = true;
				return;
			}
			release();
			var exit = !openMainMenu && !openTypesMenu && !openBatchesMenu;
			if(openMainMenu){
				openMainMenu = false;
				pushMainMenu();
			}
			if(openTypesMenu){
				openMainMenu = true;
				openTypesMenu = false;
				pushTypesMenu();
			}
			if(openBatchesMenu){
				openMainMenu = true;
				openBatchesMenu = false;
				pushBatchesMenu();
			}
			if(exit){
				if(dataStorage.session != null && dataStorage.session.isRecording()){
					Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(), transition);
				} else {
					Ui.popView(transition);
				}
			}
		}
	}
}