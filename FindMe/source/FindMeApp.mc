using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Pos;
using Toybox.System;
using Data;
using Comm;
using _;

class FindMeApp extends App.AppBase {
	var bridge;
	var dataStorage;
	
    function onStart() {
    	dataStorage = new Data.DataStorage();
    	bridge = new Comm.Bridge();
    	Data.updateCurrentLocation();
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
    	var batch = bridge.parseBatch(i);
	    dataStorage.addBatch(batch);
	    i++;
    }

}