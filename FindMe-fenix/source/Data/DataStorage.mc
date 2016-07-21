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
		
		const TIMER_INTERVAL = 1000;
		const LAST_POSITION_INTERVAL = 10;
		
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
			if(getSortBy() == null){ setSortBy(SORTBY_DATE); }
			
			locCount = getProp(KEY_LOC_TYPE, true).size();
		}
		
		function dispose(){
			timer.stop();
			timer = null;
			session = null;
			timerCallback = null;
			Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
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
			Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
			gpsFinding = false;
			if(interval >= 0){
				onTimer();
			}
			timer.start(method(:onTimer), TIMER_INTERVAL, true);
		}
		
		function onTimer(shot){
			var interval = getInterval();
			var duration = null;
			if(currentLocation != null){
				duration = Time.Time.now().subtract(currentLocation[TIMESTAMP]).value();
				if(currentLocation[ACCURACY] > Position.QUALITY_LAST_KNOWN && duration >= LAST_POSITION_INTERVAL){
					currentLocation[ACCURACY] = Position.QUALITY_LAST_KNOWN;
					invokeTimerCallback(true);
				}
			}
			if(gpsFinding){
				return;
			}
			if(interval == 0 || shot == true || (interval > 0 && (duration == null || duration >= interval))) {
				gpsFinding = true;
				Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:updateCurrentLocation));
			}
		}
		
		function updateCurrentLocation(info){
			var interval = getInterval();
			if(info.accuracy > Position.QUALITY_LAST_KNOWN && interval != 0){
				Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
				gpsFinding = false;
			}
			if(currentLocation == null && info.accuracy >= Position.QUALITY_LAST_KNOWN){
				Alert.alert(Alert.GPS_FOUND);
			}
			var radians = info.position.toRadians();
			var accuracyChanged = currentLocation == null || currentLocation[ACCURACY] != info.accuracy;
			currentLocation = [radians[0], radians[1], info.heading, info.accuracy, info.when];
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
		
		function sortLocationsList(locations){
			var sortBy = getSortBy();
			if(sortBy == SORTBY_DATE){
				return locations;
			} else if(currentLocation != null && sortBy == SORTBY_DISTANCE){
				for(var i = 0; i < locations.size(); i++){
					locations[i][LOC_DIST] = distance(locations[i][LOC_LAT], locations[i][LOC_LON], currentLocation[LAT], currentLocation[LON]);
				}
				return ArrayExt.sort(locations, method(:distanceComparer));
			} else {
				return ArrayExt.sort(locations, method(:nameComparer));
			}
		}
		
		function nameComparer(a, b){
			var t1 = a[LOC_NAME].toLower();
	    	var t2 = b[LOC_NAME].toLower();
	    	var i = 0;
	    	var d = 0;
			do {
				if(i >= t1.length() || i >= t2.length()){
					return t1.length() - t2.length();
				}
				d = t1.substring(i, i + 1).hashCode() - t2.substring(i, i + 1).hashCode();
				i++;
			} while(d == 0);
			return d;
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
						i--;
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
							i--;
							break;
						}
					}
				}
				setLocations(locations);
			}
		}
		
		function reset(){
			deleteAllLocations();
			setInterval(0);
			setDistance(0);
			setFormat(Position.GEO_DEG);
			setActivityType(ActivityRecording.SPORT_GENERIC);
			setSortBy(SORTBY_DATE);
		}
	}
}