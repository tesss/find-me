using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Data;
using Comm;
using UI;
using _;
	
class FindMeApp extends App.AppBase {
	hidden var bridge;

    function onStart() {
    	UI.dataStorage = new Data.DataStorage();
		bridge = new Comm.Bridge();
		
		var data = bridge.parseMail(0);
		UI.dataStorage.addBatch(data[0]);
	    UI.dataStorage.addLocations(data[1]);
	    data = null;
    }

    function getInitialView() {
        return [new UI.MainView()];
    }

}
		// show logo on main page
		// problem with popups
		// add notification that gps found
		// invert order of settings values
		// improve character factory
		// think about encoding and minifying name of loc
		// Jule VernGrant point on screenshots
		// limit - 100 locations - creshes on device (add limit info message)
		// transaction while saving
		// id - generated max
		// play sound when import performed and activity or vibrate
    	// indicate the quality of signal (maybe use in zero-distance)
    	// show if activity started