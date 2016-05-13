
using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Data;
using Comm;
using UI;
using _;
	
class FindMeApp extends App.AppBase {
	hidden var bridge;
	hidden var dataStorage;
	
	hidden var i = 0;

    function onStart() {
    	dataStorage = new Data.DataStorage();
		bridge = new Comm.Bridge();
		
    	var data = bridge.parseMail(i);
		dataStorage.addBatch(data[0]);
	    dataStorage.addLocations(data[1]);
    }

    function onStop() {
    }

    function getInitialView() {
        return [new UI.MainView(dataStorage)];
    }

}
		// Grant point on screenshots
		// change transition
		// limit - 100 locations - creshes on device
		// transaction while saving
		// id - generated max
		// play sound when import performed and activity or vibrate
		// add with picker
    	// show find only for supported devices (possible with picker)
    	// delete all