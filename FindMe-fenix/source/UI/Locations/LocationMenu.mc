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
			addItem("Save Persisted", :persisted);
			if(_model.size() > 1){
				addItem("Save All Persisted", :persistedAll);
			}
			addItem("Delete", :delete);
			if(_model.size() > 1){
				addItem("Delete All", :deleteAll);
			}
		}
	}
	
	class LocationMenuDelegate extends Ui.MenuInputDelegate {
		hidden var model;
	
		function initialize(_model){
			model = _model;
		}
		
		hidden function newSession(){
			return ActivityRecording.createSession({
				:name => "FM_" + Data.dateStr(), 
				:sport => dataStorage.getActivityType()
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
	    	} else if(item == :persisted){
	    		popInNotGlobal();
	    		model.get().savePersisted();
	    		pushInfoView("Saved successfully", model.global);
	    	} else if(item == :persistedAll){
	    		popInNotGlobal();
	    		model.get().savePersisted();
	    		pushInfoView("Saved successfully", model.global);
	    	} else if(item == :delete){
	    		var fullRefresh = model.delete();
	    		if(fullRefresh){
	    			if(model.global){
	    				openMainMenu = false;
	    				openTypesMenu = true;
	    				Ui.popView(transition);
	    			}
					Ui.popView(transition);
	    		}
	    		pushInfoView("Deleted", true);
	    	} else if(item == :deleteAll){
	    		model.deleteAll();
	    		if(model.global){
    				openMainMenu = false;
    				openTypesMenu = true;
    				Ui.popView(transition);
    			}
				Ui.popView(transition);
	    		pushInfoView("Deleted", true);
	    	}
	    }
    }
}