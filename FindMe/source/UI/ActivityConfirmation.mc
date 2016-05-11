using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class ActivityConfirmationDelegate extends Ui.ConfirmationDelegate {
		hidden var dataStorage;
		hidden var exit;
		
		function initialize(_dataStorage, _exit){
			dataStorage = _dataStorage;
			exit = _exit;
		}
		
		function onResponse(response){
			if(response == Ui.CONFIRM_YES){
				dataStorage.session.stop();
				dataStorage.session.save();
				dataStorage.session = null;
				Ui.popView(noTransition);
			} else {
				if(exit){
					dataStorage.session.stop();
					dataStorage.session.discard();
				}
				//dataStorage.session.discard();
			}
			if(exit){
				System.exit();
			}
		}
	}
}