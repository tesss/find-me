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
			if(model.getDataStorage().session == null){
				addItem("Start Activity", :activity);
			} else {
				if(model.getDataStorage().session.isRecording){
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
			return ActivityRecording.createSession({:name => "FindMe " + Data.dateStr(Time.Time.now().value()), :sport => model.getDataStorage().getActivityType()}); // add activity type
		}
	
	    function onMenuItem(item) {
	    	var dataStorage = model.getDataStorage();
	    	if(item == :activity){
	    		if(dataStorage.session == null){
	    			dataStorage.session = newSession();
	    			dataStorage.session.start();
	    		} else if(dataStorage.session.isRecording()){
	    			Ui.pushView(new Ui.Confirmation("Save activity?"), new ActivityConfirmationDelegate(dataStorage), noTransition);
	    		} else {
	    			dataStorage.session = newSession();
	    			dataStorage.session.start(); // check for error
	    		}
	    	} else if(item == :coord){
	    		Ui.pushView(new InfoView(getLocationStr(model.get().get(), dataStorage)), new InfoDelegate(), transition);
	    	} else if(item == :persisted){
	    		dataStorage.saveLocationPersisted(model.get().get()[dataStorage.LOC_ID]);
	    		Ui.pushView(new InfoView("Saved successfully"), new InfoDelegate(), transition);
	    	} else if(item == :delete){
	    		var fullRefresh = model.delete();
	    		if(fullRefresh){
	    			Ui.popView(noTransition);
					Ui.popView(noTransition);
					Ui.popView(noTransition);
					pushTypesMenu(dataStorage);
	    		}
	    		Ui.pushView(new InfoView("Deleted"), new InfoDelegate(!fullRefresh), transition);
	    		// deleted not all items
	    	}
	    }
    }
}