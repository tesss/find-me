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

    function onKey() {
    	var data = bridge.parseMail(i);
    	dataStorage.updateCurrentLocation();
    	// transaction while saving
    	// id - generated max
	    dataStorage.addBatch(data[0]);
	    dataStorage.addLocations(data[1]);
	    data = null;
	    //var types = dataStorage.getTypesList();
	    //for(var i = 0; i < types.size(); i++){
	    //	if(i == 0){
	    // 		_.p("All");
	    //	} else {
	    //		_.p(Data.DataStorage.TYPES[i - 1]);
	    //	}
	    //	for(var j = 0; j < types[i].size(); j++){
	    //		_.p(types[i][j]);
	    //	}
	    //}
	    //_.p(dataStorage.getBatches().toString());
	    _.p(dataStorage.getLocations().toString(dataStorage.currentLocation));
	    i++;
    }

}