using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Time;
using Data;
using _;

module UI{
	class LocationMenu extends Ui.Menu {
		hidden var model;
		
		function initialize(_model){
			model = _model;
			setTitle(model.get()[Data.LOC_NAME]);
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
			if(Toybox has :PersistedLocations){
				addItem("Save Persisted", :persisted);
			}
			addItem("Delete", :delete);
		}
	}
	
	class LocationMenuDelegate extends Ui.MenuInputDelegate {
		hidden var model;
	
		function initialize(_model){
			model = _model;
		}
		
		hidden function newSession(){
			return ActivityRecording.createSession({:name => "FindMe " + Data.dateStr(Time.Time.now().value()), :sport => model.dataStorage.getActivityType()}); // add activity type
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
	    			dataStorage.session.start();
	    		} else if(dataStorage.session.isRecording()){
	    			Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(), transition);
	    		} else {
	    			dataStorage.session = newSession();
	    			dataStorage.session.start(); // check for error
	    		}
	    	} else if(item == :coord){
	    		popInNotGlobal();
	    		pushInfoView(getLocationStr(model.get().get()), null, model.global);
	    	} else if(item == :persisted){
	    		popInNotGlobal();
	    		dataStorage.saveLocationPersisted(model.get().get()[dataStorage.LOC_ID]);
	    		pushInfoView("Saved successfully", null, model.global);
	    	} else if(item == :delete){
	    		popInNotGlobal();
	    		var fullRefresh = model.delete();
	    		if(fullRefresh && model.global){
	    			Ui.popView(transition);
					Ui.popView(transition);
					Ui.popView(transition);
					pushTypesMenu();
	    		}
	    		pushInfoView("Deleted", null, !fullRefresh && model.global || fullRefresh && !model.global);
	    	}
	    }
    }
}