using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Pos;
using Toybox.System;
using Data;
using Comm;
using Toybox.Math;
using _;

// only arrays without objects
// 4*5 = 59.4kb
// 300 loc = 35.7kb memory
// ~400 items in array - limit;

class FindMeApp extends App.AppBase {
	var bridge;
	var dataStorage;

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
	var bridge;
	var dataStorage;
	var i = 0;

	function initialize(_bridge, _dataStorage){
		bridge = _bridge;
		dataStorage = _dataStorage;
	}

    function onKey() {
    	dataStorage.updateCurrentLocation();
    	var data = bridge.parseMail(i);
	    dataStorage.addBatch(data[0]);
	    dataStorage.addLocations(data[1]);
	    //var t = dataStorage.getTypesList();
	    //var t = dataStorage.getBatchesList();
	    //_.p(dataStorage.getBatches().toString());
	    _.p(dataStorage.getLocations().toString());
	    i++;
    }

}