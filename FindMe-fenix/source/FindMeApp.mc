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

		// improve character factory
		// think about encoding and minifying name of loc
		// Jule VernGrant point on screenshots
		// transaction while saving
		// id - generated max
		// import alert

    	// bugs