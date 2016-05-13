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
			if(getFormat() == null){ setFormat(Position.GEO_MGRS); }
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
				timer.start(method(:onTimer), interval, true);
			}
		}
		
		function onTimer(interval){
			if(interval == -1){
				Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
				currentLocation = null;
			} else if(interval == 0){
				Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:updateCurrentLocation));
			} else {
				Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:updateCurrentLocation));
			}
		}
		
		function updateCurrentLocation(info){
			var radians = info.position.toRadians();
			currentLocation = [radians[0], radians[1], info.heading, info.accuracy];
			invokeTimerCallback();
		}
		
		// timer
		
		function getLocations(){
			return new Locations(getProp(KEY_LOC_NAME), getProp(KEY_LOC_LAT), getProp(KEY_LOC_LON), getProp(KEY_LOC_TYPE), getProp(KEY_LOC_BATCH));
		}
		
		hidden function setLocations(locations){
			setProp(KEY_LOC_LAT, locations.latitudes);
			setProp(KEY_LOC_LON, locations.longitudes);
			setProp(KEY_LOC_TYPE, locations.types);
			setProp(KEY_LOC_BATCH, locations.batches);
			setProp(KEY_LOC_NAME, locations.names);
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
				location = [0, toDegrees(currentLocation[LAT]) + ", " + Math.toDegrees(currentLocation[LON]), currentLocation[LAT], currentLocation[LON], TYPES.size() - 1, -1];
			}
			var newLocations = new Locations([location[LOC_NAME]], [location[LOC_LAT]], [location[LOC_LON]], [location[LOC_TYPE]], [location[LOC_BATCH]]);
			return addLocations(newLocations);
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
			var ids = {};
			for(var i = 0; i < newLocations.size(); i++){
				for(var j = 0; j < locations.size(); j++){
					if( newLocations.names[i] == locations.names[j] &&
						newLocations.latitudes[i] == locations.latitudes[j] && 
						newLocations.longitudes[i] == locations.longitudes[j] &&
						newLocations.types[i] == locations.types[j] &&
						newLocations.batches[i] == locations.batches[j]){
						ids.put(i, j);
						break;
					}
				}
			}
			return ids;
		}
		
		function addBatch(batch){
			var batches = getBatches();
			batches.ids = ArrayExt.insertAt(batches.ids, batch[BATCH_ID], 0);
			batches.names = ArrayExt.insertAt(batches.names, batch[BATCH_NAME], 0);
			batches.dates = ArrayExt.insertAt(batches.dates, batch[BATCH_DATE], 0);
			setBatches(batches);
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
		
		function deleteBatch(id){
			var batches = getBatches();
			var index = -1;
			for(var i = 0; i < batches.size(); i++){
				if(batches.ids[i] == i){
					index = i;
					break;
				}
			}
			batches.remove(index);
			setBatches(batches);
			batches = null;
			var locations = getLocations();
			for(var i = 0; i < locations.size(); i++){
				if(locations.batches[i] == id){
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
			PersistedLocations.persistLocation(new Position.Location({
				:latitude => locations.latitudes[i], 
				:longitude => locations.longitudes[i], 
				:format => :radians}), {
				:name => locations.names[i]
			});
		}
		
		function saveBatchPersisted(id){
			var locations = getLocations();
			for(var i = 0; i < locations.size(); i++){
				if(locations.batches[i] == id){
					PersistedLocations.persistLocation(new Position.Location({
						:latitude => locations.latitudes[i], 
						:longitude => locations.longitudes[i], 
						:format => :radians}), {
						:name => location.names[i]
					});
				}
			}
		}
	}
}