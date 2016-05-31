using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Time;
using Data;
using Alert;
using _;

module UI{
	class LocationMenu extends Ui.Menu {
		function initialize(_model){
			setTitle(_model.get()[Data.LOC_NAME]);
			if(dataStorage.session == null){
				addItem("Start Activity", :activity);
			} else {
				if(dataStorage.session.isRecording){
					addItem("Stop Activity", :activity);
				} else {
					addItem("Start Activity", :activity);
				}
			}
			addItem("Coordinates", :coord);
			addItem("Delete", :delete);
		}
	}
	
	class LocationMenuDelegate extends Ui.MenuInputDelegate {
		hidden var model;
	
		function initialize(_model){
			model = _model;
		}
		
		hidden function newSession(){
			return ActivityRecording.createSession({
				:name => "FindMe " + Data.dateStr(), 
				:sport => model.dataStorage.getActivityType()
			});
		}
		
		hidden function popInNotGlobal(){
			if(!model.global){
	    		Ui.popView(transition);
	    	}
		}
	
	    function onMenuItem(item) {
	    	if(item == :activity){
	    		if(dataStorage.session == null){
	    			dataStorage.session = newSession();
	    			if(!dataStorage.session.start()){
	    				pushInfoView("Start error", model.global, true);
	    				Alert.alert(Alert.ACTIVITY_FAILURE);
	    			} else {
	    				Alert.alert(Alert.ACTIVITY_START);
	    			}
	    		} else if(dataStorage.session.isRecording()){
	    			Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(), transition);
	    		}
	    	} else if(item == :coord){
	    		popInNotGlobal();
	    		pushInfoView(getLocationStr(model.get().get()), model.global);
	    	} else if(item == :delete){
	    		var fullRefresh = model.delete();
	    		if(fullRefresh){
	    			if(model.global){
	    				Ui.popView(transition);
	    				openTypesMenu = true;
	    			}
					Ui.popView(transition);
					Ui.popView(transition);
					openMainMenu = true;
	    		}
	    		pushInfoView("Deleted", !fullRefresh && model.global || fullRefresh && !model.global);
	    	}
	    }
    }
}