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
			setTitle("Location");
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
	
	    function onMenuItem(item) {
	    	if(item == :activity){
	    		if(dataStorage.session == null){
	    			dataStorage.session = newSession();
	    			dataStorage.session.start();
	    		} else if(dataStorage.session.isRecording()){
	    			Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(), noTransition);
	    		} else {
	    			dataStorage.session = newSession();
	    			dataStorage.session.start(); // check for error
	    		}
	    	} else if(item == :coord){
	    		pushInfoView(getLocationStr(model.get().get()));
	    	} else if(item == :persisted){
	    		dataStorage.saveLocationPersisted(model.get().get()[dataStorage.LOC_ID]);
	    		pushInfoView("Saved successfully");
	    	} else if(item == :delete){
	    		var fullRefresh = model.delete();
	    		if(fullRefresh){
	    			Ui.popView(noTransition);
					Ui.popView(noTransition);
					Ui.popView(noTransition);
					pushTypesMenu();
	    		}
	    		pushInfoView("Deleted", null, !fullRefresh);
	    	}
	    }
    }
}