using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	class ActivityConfirmationDelegate extends Ui.ConfirmationDelegate {
		hidden var exit;
		
		function initialize(_exit){
			exit = _exit == true;
		}
		
		function onResponse(response){
			if(response == Ui.CONFIRM_YES){
				dataStorage.session.stop();
				dataStorage.session.save();
				dataStorage.session = null;
				if(!exit){
					Ui.popView(transition);
				}
				//pushInfoView("Activity saved", null, false, exit);
			} else {
				dataStorage.session.stop();
				dataStorage.session.discard();
				dataStorage.session = null;
				if(!exit){
					Ui.popView(transition);
				}
				//pushInfoView("Activity discarded", null, false, exit);
			}
		}
	}
}