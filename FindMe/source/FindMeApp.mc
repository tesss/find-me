using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Pos;
using Toybox.System;
using Toybox.Time;
using Toybox.Math;
using Data;
using Comm;
using _;

class FindMeApp extends App.AppBase {
	hidden var bridge;
	hidden var dataStorage;

    function onStart() {
    	bridge = new Comm.Bridge();
    	dataStorage = new Data.DataStorage();
    }

    function onStop() {
    }

    function getInitialView() {
        return [ new FindMeView(), new FindMeDelegate(bridge, dataStorage) ];
    }

}

class FindMeDelegate extends Ui.BehaviorDelegate {
	hidden var bridge;
	hidden var dataStorage;
	hidden var i = 0;

	function initialize(_bridge, _dataStorage){
		bridge = _bridge;
		dataStorage = _dataStorage;
	}

	// optimise for 300 locations
    function onKey() {
    	var data = bridge.parseMail(i);
    	dataStorage.updateCurrentLocation();
    	// transaction while saving
    	// id - generated max
    	//dataStorage.setDistance(7000);
	    dataStorage.addBatch(data[0]);
	    dataStorage.addLocations(data[1]);
	    data = null;
	    //dataStorage.deleteBatch(0);
	    dataStorage.deleteLocation(0);
	    var locations = dataStorage.find("");
	    _.p(locations);
	    dataStorage.saveLocationPersisted(0);
	    dataStorage.saveBatchPersisted(0);
	    //var types = dataStorage.getTypesList();
	    //printTypes(types);
	    //_.p(dataStorage.getBatches().toString());
	    //_.p(dataStorage.getLocations().toString(dataStorage.currentLocation));
	    i++;
    }
	
	function printTypes(types){
		for(var i = 0; i < types.size(); i++){
	    	if(i == 0){
	     		_.p("All");
	    	} else {
	    		_.p(Data.DataStorage.TYPES[i - 1]);
	    	}
	    	for(var j = 0; j < types[i].size(); j++){
	    		_.p(types[i][j]);
	    	}
	    }
	}
}