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
			if(model.dataStorage.session == null){
				addItem("Start Activity", :activity);
			} else {
				if(model.dataStorage.session.isRecording){
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
	    	var dataStorage = model.dataStorage;
	    	if(item == :activity){
	    		if(dataStorage.session == null){
	    			dataStorage.session = newSession();
	    			dataStorage.session.start();
	    		} else if(dataStorage.session.isRecording()){
	    			Ui.pushView(new Ui.Confirmation("Stop & save activity?"), new ActivityConfirmationDelegate(dataStorage), transition);
	    		} else {
	    			dataStorage.session = newSession();
	    			dataStorage.session.start(); // check for error
	    		}
	    	} else if(item == :coord){
	    		Ui.pushView(new CoordinatesView(getLocationStr(model.get(), dataStorage)), new CoordinatesDelegate(), transition);
	    	}
	    }
    }
}