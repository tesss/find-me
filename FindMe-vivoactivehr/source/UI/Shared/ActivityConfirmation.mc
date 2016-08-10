using Toybox.WatchUi as Ui;
using Toybox.System;
using Alert;

module UI{
	class ActivityConfirmationDelegate extends Ui.ConfirmationDelegate {
		function onResponse(response){
			Ui.popView(transition);
			if(dataStorage.session.stop()){
				if(response == Ui.CONFIRM_YES){
					if(dataStorage.session.save()){
						Alert.alert(Alert.ACTIVITY_SAVE);
					} else {
						pushInfoView("Save error", true, true);
						Alert.alert(Alert.ACTIVITY_FAILURE);
					}
				} else {
					if(dataStorage.session.discard()){
						Alert.alert(Alert.ACTIVITY_DISCARD);
					} else {
						pushInfoView("Save error", true, true);
						Alert.alert(Alert.ACTIVITY_FAILURE);
					}
				}
				dataStorage.session = null;	
			} else {
				pushInfoView("Stop error", true, true);
				Alert.alert(Alert.ACTIVITY_FAILURE);
			}
		}
	}
}