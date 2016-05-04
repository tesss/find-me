using Toybox.System;
using Toybox.Application;
using Toybox.Math;
using Toybox.Time;
using Toybox.Position;
using _;

module Data{
	class DataStorage {
		static const types = ["city", "lake", "river", "mountain", "spring", "bus_station"];
		
		var currentLocation;
		function updateCurrentLocation(){ // update in timer
			currentLocation = Position.getInfo();
		}
		
		var app = null;
		
		function initialize(){
			app = Application.getApp().weak();
			initProp(LOC_NAME); initProp(LOC_LAT); initProp(LOC_LON); initProp(LOC_TYPE); initProp(LOC_BATCH);
			initProp(BATCH_ID); initProp(BATCH_NAME); initProp(BATCH_DATE);
			if(getSortBy() == null){ setSortBy(SORTBY_DISTANCE); }
		}
		
		// props //
		
		hidden function getApp(){ return app.get(); }		
		hidden function getProp(key){ return getApp().getProperty(key); }		
		hidden function setProp(key, value){ getApp().setProperty(key, value); }		
		hidden function initProp(key){ if(getProp(key) == null){ setProp(key, []); } }
		
		// options //
		
		function getSortBy(){ return getProp(SORT); }	
		function setSortBy(sortBy){ setProp(SORT, sortBy); setLocations(sortLocations(getLocations(), sortBy)); }	
		function getDistance(){return getProp(DISTANCE);}
		function setDistance(distance){ setProp(DISTANCE, distance); }
		
		// locations //
		
		function getLocations(){
			return new Locations(getProp(LOC_NAME), getProp(LOC_LAT), getProp(LOC_LON), getProp(LOC_TYPE), getProp(LOC_BATCH));
		}
		
		hidden function setLocations(locations){
			setProp(LOC_NAME, locations.names);
			setProp(LOC_LAT, locations.latitudes);
			setProp(LOC_LON, locations.longitudes);
			setProp(LOC_TYPE, locations.types);
			setProp(LOC_BATCH, locations.batches);
		}
		
		// validate in import
		function getTypesList(){
			var locations = getLocations();
			var types = {};
			for(var i = 0; i < locations.types.size(); i++){
				var type = locations.types[i];
				var location = [locations.names[i], locations.latitudes[i], locations.longitudes[i]];
				var typeLocations = types.get(type);
				if(typeLocations == null){
					typeLocations = [];
					types.put(type, typeLocations);
				}
				ArrayExt.insertAt(typeLocations, location, typeLocations.size());
			}
			locations = null;
			return types.values();
		}
		
		// batches //
		
		function getBatches(){
			return new Batches(getProp(BATCH_ID), getProp(BATCH_NAME), getProp(BATCH_DATE));
		}
		
		hidden function setBatches(batches){
			setProp(BATCH_ID, batches.ids);
			setProp(BATCH_NAME, batches.names);
			setProp(BATCH_DATE, batches.dates);
		}
		
		function getBatchesList(){
			var batches = getBatches();
			var batchRel = {};
			for(var i = 0; i < batches.ids.size(); i++){
				batchRel.put(batches.ids[i], batches.names[i]);
			}
			batches = {};
			var locations = getLocations();	
			locations.types = null;
			var distance = getDistance();
			for(var i = 0; i < locations.batches.size(); i++){
				var batchId = locations.batches[i];
				var batchName = batchRel.get(batchId);
				if(distance == null || distance(locations.latitudes[i], locations.longitudes[i]) <= distance){				
					var location = [locations.names[i], locations.latitudes[i], locations.longitudes[i]];
					var batchLocations = batches.get(batchName);
					if(batchLocations == null){
						batchLocations = [];
						batches.put(batchName, batchLocations);
					}
					ArrayExt.insertAt(batchLocations, location, batchLocations.size());
				}
			}						
			batchRel = null;
			locations = null;
			return batches.values();
		}
		
		// show error if too much
		function addLocations(newLocations){
			var locations = getLocations();
			var sortBy = getSortBy();
			locations.names = ArrayExt.union(locations.names, newLocations.names);
			locations.latitudes = ArrayExt.union(locations.latitudes, newLocations.latitudes);
			locations.longitudes = ArrayExt.union(locations.longitudes, newLocations.longitudes);
			locations.types = ArrayExt.union(locations.types, newLocations.types);
			locations.batches = ArrayExt.union(locations.batches, newLocations.batches);
			setLocations(locations);
			locations = null;
		}
		
		function addBatch(batch){
			var batches = getBatches();
			batches.ids = ArrayExt.insertAt(batches.ids, batch.id, 0);
			batches.names = ArrayExt.insertAt(batches.names, batch.name, 0);
			batches.dates = ArrayExt.insertAt(batches.dates, batch.date, 0);
			setBatches(batches);
			batches = null;
		}
		
		// sorting //
		
		hidden function sortLocations(locations, sortBy){
			var method = null;
			var arrayToSort = null;
			if(sortBy == SORTBY_NAME){
				method = method(:nameComparer);
				arrayToSort = locations.names;
			} else if(sortBy == SORTBY_DISTANCE){
				method = method(:distanceComparer);
				arrayToSort = new[locations.latitudes.size()];
				for(var i = 0; i < arrayToSort.size(); i++){
					arrayToSort[i] = new Location(null, locations.latitudes[i], locations.longitudes[i], null, null);
				}
			}
			if(method != null){
				var sortArray = new[arrayToSort.size()];
				for(var i = 0; i < sortArray.size(); i++){
					sortArray[i] = new SortItem(i, arrayToSort[i]);
				}
				arrayToSort = null;
				sortArray = ArrayExt.sort(sortArray, method);
				for(var i = 0; i < sortArray.size(); i++){
					var key = sortArray[i].key;
					ArrayExt.swap(locations.names, i, key);
					ArrayExt.swap(locations.latitudes, i, key);
					ArrayExt.swap(locations.longitudes, i, key);
					ArrayExt.swap(locations.types, i, key);
					ArrayExt.swap(locations.batches, i, key);
				}
				sortArray = null;
			}
			return locations;
		}
		
		hidden class SortItem {
			var key;
			var value;
			
			function initialize(_key, _value){
				key = _key;
				value = _value;
			}
		}
		
		hidden function nameComparer(a, b){
			return a.value.length() - b.value.length(); // implement comparing by string
		}
		
		hidden function distanceComparer(a, b){
			return distance(a.latitude, a.longitude, b.latitude, b.longitude);
		}
		
		static function distance(latitude1, longitude1, latitude2, longitude2){
			if(latitude2 == null && longitude2 == null){
				if(currentLocations.accuracy == Position.QUALITY_NOT_AVAILABLE){
					return 0;
				}
				var degrees = currentLocation.toDegrees();
				latitude2 = degrees[0];
				longitude2 = degrees[1];
			}
			var lat1 = Math.toRadians(latitude1);
			var lat2 = Math.toRadians(latitude2);
			var lon1 = Math.toRadians(longitude1);
			var lon2 = Math.toRadians(longitude2);
			var f1 = lat1;
			var f2 = pos[0];
			var df = Math.toRadians((lat2 - lat1));
			var dy = Math.toRadians((lon2 - lon1));
			var a = Math.sin(df/2)*Math.sin(df/2) + Math.cos(f1)*Math.cos(f2)*Math.sin(dy/2)*Math.sin(dy/2);
			var c = 2 * Math.atan(Math.sqrt(a), Math.sqrt(1-a));
			var d = r * c;
			_.p("D:" + d);
			return d;
		}
	}
		
	class Location {
		var name;
		var latitude;
		var longitude;
		var type;
		var batch;
		
		function initialize(_name, _latitude, _longitude, _type, _batche){
			name = _name;
			latitude = _latitude;
			longitude = _longitude;
			type = _type;
			batch = _batch;
		}
	}
	
	class Locations {
		var names;
		var latitudes;
		var longitudes;
		var types;
		var batches;
		
		function size(){
			if(names == null){
				return 0;
			}
			return names.size();
		}
		
		function initialize(_names, _latitudes, _longitudes, _types, _batches){
			names = _names;
			latitudes = _latitudes;
			longitudes = _longitudes;
			types = _types;
			batches = _batches;
		}
		
		function toString(){
			var str = "";
			for(var i = 0; i < size(); i++){
				str = str + names[i] + " " + latitudes[i] + " " + longitudes[i] + " " + types[i] + " " + batches[i] + "\n";
			}
			return str;
		}
	}
	
	class Batch {
		var id;
		var name;
		var date;
		
		function initialize(_id, _name, _date){
			id = _id;
			name = _name;
			date = _date;
		}
	}
	
	class Batches {
		var ids;
		var names;
		var dates;
		
		function initialize(_ids, _names, _dates){
			ids = _ids;
			names = _names;
			dates = _dates;
		}
		
		function size(){
			if(ids == null){
				return 0;
			}
			return ids.size();
		}
		
		function toString(){
			var str = "";
			for(var i = 0; i < size(); i++){
				var date = Time.Gregorian.info(new Time.Moment(dates[i]), Time.FORMAT_SHORT);
				var dateStr = date.hour + ":" + date.min + ":" + date.sec;
				str = str + ids[i] + " " + names[i] + " " + dateStr + "\n";
			}
			return str;
		}
	}
	
	enum {
		SORTBY_NAME,
		SORTBY_DISTANCE
	}
	
	enum {
		SORT,
		DISTANCE,
		
		LOC_LAT,
		LOC_LON,
		LOC_NAME,
		LOC_TYPE,
		LOC_BATCH,
		
		BATCH_ID,
		BATCH_NAME,
		BATCH_DATE
	}
}