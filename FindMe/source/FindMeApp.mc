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
	    data = null;
    }

    function onStop() {
    }

    function getInitialView() {
        return [new UI.MainView(dataStorage), new UI.MainDelegate(dataStorage)];
    }

}

class FindMeDelegate extends Ui.BehaviorDelegate {
	hidden var bridge;
	hidden var i = 0;

	function initialize(_bridge){
		bridge = _bridge;
		dataStorage = _dataStorage;
	}

    function onKey() {
    	

    }
	
	function printTypes(types){
		// optimise for 300 locations
		//var data = bridge.parseMail(i);
    	// transaction while saving
    	// id - generated max
    	// optimise for 300 locations
    	// start activity from location menu
    	// play sound when import performed or vibrate
    	// show find only for supported devices
    	
		//dataStorage.setDistance(7000);
	    //dataStorage.addBatch(data[0]);
	    //dataStorage.addLocations(data[1]);
	    //data = null;
	    //dataStorage.deleteBatch(0);
	    //dataStorage.deleteLocation(0);
	    //var locations = dataStorage.find("");
	    //_.p(locations);
	    //dataStorage.saveLocationPersisted(0);
	    //dataStorage.saveBatchPersisted(0);
	    dataStorage.updateCurrentLocation();
	    //var typeIndex = 1;
	    //var locationIndex = 0;
	    //var sorted = dataStorage.sortLocationsList(types[typeIndex], Data.SORTBY_DISTANCE, types[typeIndex][locationIndex][0]);
	    //_.p("INDEX: " + sorted[1]);
	    //types[typeIndex] = sorted[0];
	    dataStorage.addLocation();
	    types = dataStorage.getTypesList();
	    printTypes(types);
	    //_.p(dataStorage.getBatches().toString());
	    //_.p(dataStorage.getLocations().toString(dataStorage.currentLocation));
	    i++;
		for(var i = 0; i < types.size(); i++){
	    	if(i == 0){
	     		_.p("All");
	    	} else {
	    		var key = types[i][0][4];
	    		_.p(Data.DataStorage.TYPES[key]);
	    	}
	    	for(var j = 0; j < types[i].size(); j++){
	    		_.p(types[i][j]);
	    	}
	    }
	}
}