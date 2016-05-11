using Toybox.System;
using Toybox.Application;
using Toybox.Math;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Position;
using Toybox.PersistedLocations;
using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using _;

module Data{
	class DataStorage {
		static const TYPES = ["City", "Lake", "River", "Mountain", "Spring", "Bus Station", "Custom"];
		
		var app = null;
		var deviceSettings;
		var timer;
		var gpsInProgress;
		var currentLocation;
		var session;
		var timerCallback;
		
		function initialize(){
			app = Application.getApp().weak();
			timer = new Timer.Timer();
			
			deviceSettings = System.getDeviceSettings();
			
			clearProp(KEY_LOC_NAME); clearProp(KEY_LOC_LAT); clearProp(KEY_LOC_LON); clearProp(KEY_LOC_TYPE); clearProp(KEY_LOC_BATCH);
			clearProp(KEY_BATCH_ID); clearProp(KEY_BATCH_NAME); clearProp(KEY_BATCH_DATE);
			clearProp(KEY_SORT); clearProp(KEY_DISTANCE); clearProp(KEY_INTERVAL); clearProp(KEY_FORMAT); clearProp(KEY_ACT_TYPE);
			
			initProp(KEY_LOC_NAME); initProp(KEY_LOC_LAT); initProp(KEY_LOC_LON); initProp(KEY_LOC_TYPE); initProp(KEY_LOC_BATCH);
			initProp(KEY_BATCH_ID); initProp(KEY_BATCH_NAME); initProp(KEY_BATCH_DATE);
			
			if(getSortBy() == null){ setSortBy(SORTBY_DISTANCE); }
			if(getInterval() == null){ setInterval(0); }
			if(getFormat() == null){ setFormat(Position.GEO_DEG); }
			if(getActivityType() == null){ setActivityType(ActivityRecording.SPORT_GENERIC); }
		}
		
		// props
		
		hidden function getApp(){ return app.get(); }		
		hidden function getProp(key){ return getApp().getProperty(key); }		
		hidden function setProp(key, value){ getApp().setProperty(key, value); }		
		hidden function initProp(key){ if(getProp(key) == null){ setProp(key, []); } }
		hidden function clearProp(key){ setProp(key, null); }
		
		// options
		
		function getSortBy(){ return getProp(KEY_SORT); }	
		function setSortBy(sortBy){ setProp(KEY_SORT, sortBy); setLocations(sortLocations(getLocations(), sortBy)); }	
		function getDistance(){ return getProp(KEY_DISTANCE); }
		function setDistance(distance){ setProp(KEY_DISTANCE, distance); }
		function getInterval(){ return getProp(KEY_INTERVAL); }
		function setInterval(interval){ setProp(KEY_INTERVAL, interval); startTimer(interval); }
		function getFormat(){ return getProp(KEY_FORMAT); }
		function setFormat(format){ setProp(KEY_FORMAT, format); }
		function getActivityType(){ return getProp(KEY_ACT_TYPE); }
		function setActivityType(activityType){ return setProp(KEY_ACT_TYPE, activityType); }
		
		// timer
		
		hidden function invokeTimerCallback(){
			if(timerCallback != null && timerCallback.stillAlive()){
				timerCallback.get().invoke();
			}
		}
		
		hidden function startTimer(interval){
			timer.stop();
			if(interval <= 0){
				onTimer(interval);
			} else {
				timer.start(method(:onTimer), interval, false);
			}
		}
		
		function onTimer(interval){
			if(interval == -1){
				Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
				currentLocation = null;
				Ui.requestUpdate();
			} else if(interval == 0){
				Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:updateCurrentLocation));
			} else {
				if(gpsInProgress){
					currentLocation = null;
					Ui.requestUpdate();
				} else {
					gpsInProgress = true;
					Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:updateCurrentLocation));
				}
			}
		}
		
		function updateCurrentLocation(info){
			gpsInProgress = false;
			if(info.accuracy == Position.QUALITY_NOT_AVAILABLE){
				currentLocation = null;
			} else {
				currentLocation = info.position.toRadians();
			}
			invokeTimerCallback();
		}
		
		// timer
		
		function getLocations(){
			return new Locations(getProp(KEY_LOC_NAME), getProp(KEY_LOC_LAT), getProp(KEY_LOC_LON), getProp(KEY_LOC_TYPE), getProp(KEY_LOC_BATCH));
		}
		
		hidden function setLocations(locations){
			setProp(KEY_LOC_NAME, locations.names);
			setProp(KEY_LOC_LAT, locations.latitudes);
			setProp(KEY_LOC_LON, locations.longitudes);
			setProp(KEY_LOC_TYPE, locations.types);
			setProp(KEY_LOC_BATCH, locations.batches);
		}
		
		// validate in import
		function getTypesList(){
			var locations = getLocations();
			var types = {};
			var all = {};
			var lat = null;
			var lon = null;
			var distance = getDistance();
			if(currentLocation != null && distance != null){
				lat = currentLocation[LAT];
				lon = currentLocation[LON];
			}
			for(var i = 0; i < locations.size(); i++){
				var type = locations.types[i];
				var location = locations.get(i, lat, lon);
				if(location[LOC_DIST] == null || distance == null || location[LOC_DIST] <= distance){
					all.put(i, location);
					var typeLocations = types.get(type);
					if(typeLocations == null){
						typeLocations = [location];
						types.put(type, typeLocations);
					} else {
						types.put(type, ArrayExt.insertAt(typeLocations, location, typeLocations.size()));
					}
					typeLocations = null;
				}
			}
			locations = null;
			all = all.values();
			var keys = types.keys();
			var values = types.values();
			types = null;
			var indexes = new[keys.size()];
			for(var i = 0; i < indexes.size(); i++){
				indexes[i] = [i, keys[i]];
			}
			indexes = ArrayExt.sort(indexes, method(:numberComparer)); 
			values = ArrayExt.sortByIndex(values, indexes, method(:indexGetter));
			indexes = null;
			values = ArrayExt.insertAt(values, all, 0);
			for(var i = 0; i < values.size(); i++){
				values[i] = sortLocationsList(values[i], null)[0];
			}
			return values;
		}
		
		// batches
		
		function getBatches(){
			return new Batches(getProp(KEY_BATCH_ID), getProp(KEY_BATCH_NAME), getProp(KEY_BATCH_DATE));
		}
		
		hidden function setBatches(batches){
			setProp(KEY_BATCH_ID, batches.ids);
			setProp(KEY_BATCH_NAME, batches.names);
			setProp(KEY_BATCH_DATE, batches.dates);
		}
		
		function getBatchesList(){
			var batches = getBatches();
			var batchesList = new[batches.size()];
			for(var i = 0; i < batches.size(); i++){
				batchesList[i] = batches.get(i);
			}
			return batchesList;
		}
		
		function addLocation(location){
			if(location == null){
				if(currentLocation == null){
					return;
				}
				location = [0, Math.toDegrees(currentLocation[LAT]) + ", " + Math.toDegrees(currentLocation[LON]), currentLocation[LAT], currentLocation[LON], TYPES.size() - 1, -1];
			}
			var newLocations = new Locations([location[LOC_NAME]], [location[LOC_LAT]], [location[LOC_LON]], [location[LOC_TYPE]], [location[LOC_BATCH]]);
			addLocations(newLocations);
			newLocations = null;
		}
		
		// show error if too much
		function addLocations(newLocations){
			var locations = getLocations();
			locations.names = ArrayExt.union(locations.names, newLocations.names);
			locations.latitudes = ArrayExt.union(locations.latitudes, newLocations.latitudes);
			locations.longitudes = ArrayExt.union(locations.longitudes, newLocations.longitudes);
			locations.types = ArrayExt.union(locations.types, newLocations.types);
			locations.batches = ArrayExt.union(locations.batches, newLocations.batches);
			locations = sortLocations(locations);
			setLocations(locations);
			locations = null;
		}
		
		function addBatch(batch){
			var batches = getBatches();
			batches.ids = ArrayExt.insertAt(batches.ids, batch[BATCH_ID], 0);
			batches.names = ArrayExt.insertAt(batches.names, batch[BATCH_NAME], 0);
			batches.dates = ArrayExt.insertAt(batches.dates, batch[BATCH_DATE], 0);
			setBatches(batches);
			batches = null;
		}
		
		// sorting
		
		function sortLocations(locations){
			var sortBy = getSortBy();
			var method = null;
			var arrayToSort = null;
			if(sortBy == SORTBY_NAME || currentLocation == null){
				method = method(:nameComparer);
				arrayToSort = locations.names;
			} else if(false && sortBy == SORTBY_DISTANCE){
				method = method(:numberComparer);
				arrayToSort = new[locations.size()];
				for(var i = 0; i < arrayToSort.size(); i++){
					arrayToSort[i] = distance(locations.latitudes[i], locations.longitudes[i], currentLocation[0], currentLocation[1]);
				}
			}
			if(method != null){
				var indexes = new[arrayToSort.size()];
				for(var i = 0; i < indexes.size(); i++){
					indexes[i] = [i, arrayToSort[i]];
				}
				arrayToSort = null;
				indexes = ArrayExt.sort(indexes, method);
				locations.names = ArrayExt.sortByIndex(locations.names, indexes, method(:indexGetter));
				locations.latitudes = ArrayExt.sortByIndex(locations.latitudes, indexes, method(:indexGetter));
				locations.longitudes = ArrayExt.sortByIndex(locations.longitudes, indexes, method(:indexGetter));
				locations.types = ArrayExt.sortByIndex(locations.types, indexes, method(:indexGetter));
				locations.batches = ArrayExt.sortByIndex(locations.batches, indexes, method(:indexGetter));
				indexes = null;
			}
			return locations;
		}
		
		function sortLocationsList(locations, id){ // on load
			var sortBy = getSortBy();
			if(currentLocation != null && sortBy == SORTBY_DISTANCE){
				for(var i = 0; i < locations.size(); i++){
					locations[i][LOC_DIST] = distance(locations[i][LOC_LAT], locations[i][LOC_LON], currentLocation[LAT], currentLocation[LON]);
				}
				locations = ArrayExt.sort(locations, method(:distanceComparer));
			}
			if(id == null){
				return [locations, null];
			}
			return [locations, ArrayExt.indexOf(locations, id, method(:idPredicate))];
		}
		
		function nameComparer(a, b){
			var h1 = a[LOC_NAME].substring(0, 2).hashCode();
			var h2 = b[LOC_NAME].substring(0, 2).hashCode();
			return h1 - h2;
		}
		
		function numberComparer(a, b){
			return a[VALUE] - b[VALUE];
		}
		
		function distanceComparer(a, b){
			return a[LOC_DIST] - b[LOC_DIST];
		}
		
		function indexComparer(item, index){
			return item[KEY] == index;
		}
		
		function indexGetter(index){
			return index[KEY];
		}
		
		function idPredicate(item, id){
			return item[LOC_ID] == id;
		}
		
		function find(str){
			str = str.toLower();
			var types = {};
			for(var i = 0; i < TYPES.size(); i++){
				if(TYPES[i].toLower().find(str) != null){
					types.put(i, i);
				}
			}
			var locations = getLocations();
			var locationsList = {};
			var lat = null;
			var lon = null;
			var distance = getDistance();
			if(currentLocation != null){
				lat = currentLocation[LAT];
				lon = currentLocation[LON];
			}
			for(var i = 0; i < locations.size(); i++){
				if(str == "" || locations.names[i].toLower().find(str) != null || types.hasKey(locations.types[i])){
					var location = locations.get(i, lat, lon);
					if(distance == null || currentLocation == null || (currentLocation != null && location[LOC_DIST] <= distance)){
						locationsList.put(i, location);
					}
				}
			}
			locations = null;
			types = null;
			locationsList = locationsList.values();
			var method;
			if(currentLocation != null){
				method = method(:distanceComparer);
			} else {
				method = method(:nameComparer);
			}
			return ArrayExt.sort(locationsList, method);
		}
		
		// deleting
		
		function deleteBatch(i){
			var batches = getBatches();
			var batchId = batches.ids[i];
			batches.remove(i);
			setBatches(batches);
			batches = null;
			var locations = getLocations();
			for(var i = 0; i < locations.size(); i++){
				if(locations.batches[i] == batchId){
					locations.remove(i);
					i--;
				}
			}
			setLocations(locations);
			locations = null;
		}
		
		function deleteLocation(i){
			var locations = getLocations();
			locations.remove(i);
			setLocations(locations);
			locations = null;
		}
		
		// persisted
		
		function saveLocationPersisted(i){ // check if has persisted
			var locations = getLocations();
			PersistedLocations.persistLocation(new Position.Location({:latitude => locations.latitudes[i], :longitude => locations.longitudes[i], :format => :radians}));
		}
		
		function saveBatchPersisted(i){
			var batches = getBatches();
			var batchId = batches.ids[i];
			batches = null;
			var locations = getLocations();
			for(var i = 0; i < locations.size(); i++){
				if(locations.batches[i] == batchId){
					PersistedLocations.persistLocation(new Position.Location({:latitude => locations.latitudes[i], :longitude => locations.longitudes[i], :format => :radians}));
				}
			}
		}
	}
	
	const r = 6371;
	
	function distance(lat1, lon1, lat2, lon2){
		var dLat = lat2 - lat1;
		var dLon = lon2 - lon1;
		var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
		        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
		return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	}
	
	function bearing(lat1, lon1, lat2, lon2){
		var dLon = lon2 - lon1;
		var y = Math.sin(dLon) * Math.cos(lat2);
		var x = Math.cos(lat1) * Math.sin(lat2) - 
				Math.sin(lon1) * Math.cos(lon2) * Math.cos(dLon);
		return Math.toDegrees(Math.atan2(y, x));
	}
	
	function dateStr(moment){
		var date = Time.Gregorian.info(new Time.Moment(moment), Time.FORMAT_SHORT);
		var dateStr = date.day + "." + date.month + "." + date.year + " " + date.hour + ":" + date.min + ":" + date.sec;
		return dateStr;
	}
	
	enum {
		SORTBY_NAME,
		SORTBY_DISTANCE
	}
	
	enum {
		LAT,
		LON
	}
	
	enum {
		KEY_SORT,
		KEY_DISTANCE,
		KEY_INTERVAL,
		KEY_FORMAT,
		KEY_ACT_TYPE,
		
		KEY_LOC_LAT,
		KEY_LOC_LON,
		KEY_LOC_NAME,
		KEY_LOC_TYPE,
		KEY_LOC_BATCH,
		
		KEY_BATCH_ID,
		KEY_BATCH_NAME,
		KEY_BATCH_DATE
	}
	
	enum {
		KEY,
		VALUE
	}
	
	enum {
		LOC_ID,
		LOC_NAME,
		LOC_LAT,
		LOC_LON,
		LOC_TYPE,
		LOC_BATCH,
		LOC_DIST
	}
	
	enum {
		BATCH_ID,
		BATCH_NAME,
		BATCH_DATE
	}
}