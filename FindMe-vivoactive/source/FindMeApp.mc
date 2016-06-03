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

		//var locations = bridge.parseMail();
		//if(!UI.dataStorage.checkLocCount(locations.size())){
		//	return;
		//}
	    UI.dataStorage.addLocations(locations);
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

		// improve heading
    	
    	// register onImport after open mainView