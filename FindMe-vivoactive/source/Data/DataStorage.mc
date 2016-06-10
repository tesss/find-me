using Toybox.System;
using Toybox.Application;
using Toybox.Math;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Position;
using Toybox.ActivityRecording;
using Toybox.Lang;
using Alert;
using _;

module Data{
	class DataStorage {
		static const TYPES = [
			"Place",
			"Highway",
			"Sport",
			"Mountain",
			"Water",
			"Tourism",
			"Natural",
			"Hotel",
			"Sight",
			"Transport",
			"Shop",
			"Food",
			"Entertainment",
			"Emergency",
			"Tactical",
			"Custom"
		];
		
		var app = null;
		var timer;
		var currentLocation;
		var session;
		var timerCallback;
		var locCount;
		var cache;
		var gpsFinding;
		
		function initialize(){
			app = Application.getApp().weak();
			timer = new Timer.Timer();
			cache = new [5];
			gpsFinding = false;
			
			initProp(KEY_LOC_NAME); initProp(KEY_LOC_LAT); initProp(KEY_LOC_LON); initProp(KEY_LOC_TYPE);
			
			var interval = getInterval();
			if(interval == null){
				interval = 0; 
				setInterval(interval);
			} else {
				startTimer(interval);
			}
			
			if(getDistance() == null){ setDistance(0); }
			if(getFormat() == null){ setFormat(Position.GEO_DEG); }
			if(getActivityType() == null){ setActivityType(ActivityRecording.SPORT_GENERIC); }
			if(getSortBy() == null){ setSortBy(SORTBY_DISTANCE); }
			
			locCount = getProp(KEY_LOC_TYPE, true).size();
		}
		
		// props
		
		hidden function getApp(){ return app.get(); }
		
		hidden function getProp(key, noCache){
			if(noCache == true){
				return getApp().getProperty(key);
			}
			if(cache[key] == null){
				cache[key] = getApp().getProperty(key);
			}
			return cache[key];
		}	
			
		hidden function setProp(key, value, noCache){
			if(noCache != true){
				cache[key] = value;
			}
			getApp().setProperty(key, value); 
		}
				
		hidden function initProp(key){ if(getProp(key, true) == null){ setProp(key, [], true); } }
		hidden function clearProp(key){ setProp(key, null, true); }
		
		// options
		
		function getSortBy(){ return getProp(KEY_SORT); }	
		function setSortBy(sortBy){ setProp(KEY_SORT, sortBy); }	
		function getDistance(){ return getProp(KEY_DISTANCE); }
		function setDistance(distance){ setProp(KEY_DISTANCE, distance); }
		function getInterval(){ return getProp(KEY_INTERVAL); }
		function setInterval(interval){ setProp(KEY_INTERVAL, interval); startTimer(interval); }
		function getFormat(){ return getProp(KEY_FORMAT); }
		function setFormat(format){ setProp(KEY_FORMAT, format); }
		function getActivityType(){ return getProp(KEY_ACT_TYPE); }
		function setActivityType(activityType){ return setProp(KEY_ACT_TYPE, activityType); }
		
		// timer
		
		hidden function invokeTimerCallback(accuracyChanged){
			if(timerCallback != null){
				timerCallback.invoke(accuracyChanged);
			}
		}
		
		hidden function startTimer(interval){
			timer.stop();
			if(interval <= 0){
				onTimer();
			} else {
				timer.start(method(:onTimer), interval * 1000, true);
			}
		}
		
		function onTimer(){
			if(gpsFinding){
				return;
			}
			var interval = getInterval();
			if(interval == -1){
				Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
				var accuracyChanged = currentLocation != null;
				currentLocation = null;
				invokeTimerCallback(accuracyChanged);
			} else if(interval == 0){
				gpsFinding = true;
				Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:updateCurrentLocation));
			} else {
				gpsFinding = true;
				//Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:updateCurrentLocation));
				updateCurrentLocation(Position.getInfo());
			}
		}
		
		function updateCurrentLocation(info){
			gpsFinding = false;
			if(info.accuracy != Position.QUALITY_NOT_AVAILABLE){
				if(currentLocation == null || currentLocation[ACCURACY] == Position.QUALITY_NOT_AVAILABLE){
					Alert.alert(Alert.GPS_FOUND);
				}
			} else {
				if(currentLocation != null && currentLocation[ACCURACY] != Position.QUALITY_NOT_AVAILABLE){
					Alert.alert(Alert.GPS_LOST);
				}
			}
			
			var radians = info.position.toRadians();
			var accuracyChanged = currentLocation == null || currentLocation[ACCURACY] != info.accuracy;
			currentLocation = [radians[0], radians[1], info.heading, info.accuracy];
			invokeTimerCallback(accuracyChanged);
		}
		
		// locations
		
		hidden function getLocations(){
			return new Locations(getProp(KEY_LOC_NAME, true), getProp(KEY_LOC_LAT, true), getProp(KEY_LOC_LON, true), getProp(KEY_LOC_TYPE, true));
		}
		
		hidden function setLocations(locations){
			setProp(KEY_LOC_NAME, locations.names, true);
			setProp(KEY_LOC_LAT, locations.latitudes, true);
			setProp(KEY_LOC_LON, locations.longitudes, true);
			setProp(KEY_LOC_TYPE, locations.types, true);
			locCount = locations.size();
		}
		
		function checkLocCount(newLocCount){
			return locCount + newLocCount <= LOC_MAX_COUNT;
		}
		
		function getTypesList(){
			var locations = getLocations();
			if(locations.size() == 0){
				return [];
			}
			var types = {};
			var all = {};
			var lat = null;
			var lon = null;
			var distance = getDistance();
			if(currentLocation != null && distance != 0){
				lat = currentLocation[LAT];
				lon = currentLocation[LON];
			}
			for(var i = 0; i < locations.size(); i++){
				var type = locations.types[i];
				var location = locations.get(i, lat, lon);
				if(location[LOC_DIST] == null || distance == 0 || location[LOC_DIST] <= distance){
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
			if(all.size() == 0){
				return [];
			}
			locations = null;
			all = all.values();
			types = ArrayExt.sort(types.values(), method(:typeComparer)); 
			types = ArrayExt.insertAt(types, all, 0);
			return types;
		}
		
		function addLocation(location){
			var newLocations = new Locations([location[LOC_NAME]], [location[LOC_LAT]], [location[LOC_LON]], [location[LOC_TYPE]]);
			return addLocations(newLocations);
		}
		
		function addLocations(newLocations){
			var locations = getLocations();
			var l = locations.size();
			locations.names = ArrayExt.union(locations.names, newLocations.names);
			locations.latitudes = ArrayExt.union(locations.latitudes, newLocations.latitudes);
			locations.longitudes = ArrayExt.union(locations.longitudes, newLocations.longitudes);
			locations.types = ArrayExt.union(locations.types, newLocations.types);
			setLocations(locations);
			var ids = new [newLocations.size()];
			for(var i = 0; i < ids.size(); i++){
				ids[i] = l + i;
			}
			return ids;
		}
		
		// sorting
		
		function sortLocationsList(locations, id){ // on load
			var sortBy = getSortBy();
			if(currentLocation != null && sortBy == SORTBY_DISTANCE){
				for(var i = 0; i < locations.size(); i++){
					locations[i][LOC_DIST] = distance(locations[i][LOC_LAT], locations[i][LOC_LON], currentLocation[LAT], currentLocation[LON]);
				}
				locations = ArrayExt.sort(locations, method(:distanceComparer));
			} else {
				locations = ArrayExt.sort(locations, method(:nameComparer));
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
		
		function typeComparer(a, b){
			return a[0][LOC_TYPE] - b[0][LOC_TYPE];
		}
		
		function distanceComparer(a, b){
			return a[LOC_DIST] - b[LOC_DIST];
		}
		
		function idPredicate(item, id){
			return item[LOC_ID] == id;
		}
		
		// deleting
		
		function deleteLocation(i){
			var locations = getLocations();
			locations.remove(i);
			setLocations(locations);
		}
		
		function deleteAllLocations(data){ // if null - all
			if(data == null){
				clearProp(KEY_LOC_NAME); clearProp(KEY_LOC_LAT); clearProp(KEY_LOC_LON); clearProp(KEY_LOC_TYPE);
				initProp(KEY_LOC_NAME); initProp(KEY_LOC_LAT); initProp(KEY_LOC_LON); initProp(KEY_LOC_TYPE);
				locCount = 0;
			} else if(data instanceof Toybox.Lang.Number) { // delete all of type
				var locations = getLocations();
				for(var i = 0; i < locations.size(); i++){
					if(locations.types[i] == data){
						locations.remove(i);
					}
				}
				setLocations(locations);
			} else if(data instanceof Toybox.Array){
				var locations = getLocations();
				for(var i = 0; i < locations.size(); i++){
					for(var j = 0; j < data.size(); j++){
						if(locations.ids[i] == data[j]){
							locations.remove(i);
							data = ArrayExt.removeAt(data, j);
							break;
						}
					}
				}
				setLocations(locations);
			}
		}
	}
}