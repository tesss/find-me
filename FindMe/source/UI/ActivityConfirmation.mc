using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class ActivityConfirmationDelegate extends Ui.ConfirmationDelegate {
		hidden var dataStorage;
		hidden var exit;
		
		function initialize(_dataStorage, _exit){
			dataStorage = _dataStorage;
			exit = _exit == true;
		}
		
		function onResponse(response){
			if(response == Ui.CONFIRM_YES){
				dataStorage.session.stop();
				dataStorage.session.save();
				dataStorage.session = null;
				if(!exit){
					Ui.popView(noTransition);
				}
				Ui.pushView(new InfoView("Activity saved"), new InfoDelegate(false, exit), transition);
			} else {
				dataStorage.session.stop();
				dataStorage.session.discard();
				dataStorage.session = null;
				if(!exit){
					Ui.popView(noTransition);
				}
				Ui.pushView(new InfoView("Activity discarded"), new InfoDelegate(false, exit), transition);
			}
		}
	}
}