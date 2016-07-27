using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Data;
using UI;
using _;
	
class FindMeApp extends App.AppBase {
    function onStart() {
    	UI.dataStorage = new Data.DataStorage();
    }

	function onStop(){
    	UI.dataStorage.dispose();
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
    	// register onImport after open mainView
    	// sort imported locations before show