using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Data;
//using Comm;
using UI;
using _;
	
class FindMeApp extends App.AppBase {
	hidden var bridge;
	
	hidden var i = 0;

    function onStart() {
    	UI.dataStorage = new Data.DataStorage();
		//bridge = new Comm.Bridge();
		
		//var data = bridge.parseMail(i);
		//UI.dataStorage.addBatch(data[0]);
	    //UI.dataStorage.addLocations(data[1]);
    }

    function onStop() {
    }

    function getInitialView() {
        return [new UI.MainView()];
    }

}
		// show logo on main page
		// problem with popups
		// add notification that gps found, if distance 0 - hide bearing
		// improve character factory
		// think about encoding and minifying name of loc
		// Jule VernGrant point on screenshots
		// change transition
		// limit - 100 locations - creshes on device (add limit info message)
		// transaction while saving
		// id - generated max
		// play sound when import performed and activity or vibrate
		// add with picker
    	// show find only for supported devices (possible with picker)
    	// separate into diff packages
    	// indicate the quality of signal (maybe use in zero-distance)
    	// highlight name with invert color (colors by type?)