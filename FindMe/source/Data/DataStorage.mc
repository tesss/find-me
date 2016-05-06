using Toybox.System;
using Toybox.Application;
using Toybox.Math;
using Toybox.Time;
using Toybox.Position;
using _;

module Data{
	class DataStorage {
		static const TYPES = ["City", "Lake", "River", "Mountain", "Spring", "Bus Station"];
		
		var app = null;
		
		function initialize(){
			app = Application.getApp().weak();
			
			clearProp(LOC_NAME); clearProp(LOC_LAT); clearProp(LOC_LON); clearProp(LOC_TYPE); clearProp(LOC_BATCH);
			clearProp(BATCH_ID); clearProp(BATCH_NAME); clearProp(BATCH_DATE);
			
			initProp(LOC_NAME); initProp(LOC_LAT); initProp(LOC_LON); initProp(LOC_TYPE); initProp(LOC_BATCH);
			initProp(BATCH_ID); initProp(BATCH_NAME); initProp(BATCH_DATE);
			if(getSortBy() == null){ setSortBy(SORTBY_DISTANCE); }
		}
		
		var currentLocation;
		function updateCurrentLocation(){ // update in timer
			var info = Position.getInfo();
			if(info.accuracy == Position.QUALITY_NOT_AVAILABLE){
				currentLocation = null;
			} else {
				currentLocation = info.position.toRadians();
			}
		}
		
		// props
		
		hidden function getApp(){ return app.get(); }		
		hidden function getProp(key){ return getApp().getProperty(key); }		
		hidden function setProp(key, value){ getApp().setProperty(key, value); }		
		hidden function initProp(key){ if(getProp(key) == null){ setProp(key, []); } }
		hidden function clearProp(key){ setProp(key, null); }
		
		// options
		
		function getSortBy(){ return getProp(SORT); }	
		function setSortBy(sortBy){ setProp(SORT, sortBy); setLocations(sortLocations(getLocations(), sortBy)); }	
		function getDistance(){return getProp(DISTANCE);}
		function setDistance(distance){ setProp(DISTANCE, distance); }
		
		// locations
		
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
			var all = new[locations.types.size()];
			for(var i = 0; i < locations.types.size(); i++){
				var type = locations.types[i];
				var location = [i, locations.names[i], locations.latitudes[i], locations.longitudes[i]];
				all[i] = location;
				var typeLocations = types.get(type);
				if(typeLocations == null){
					typeLocations = [location];
					types.put(type, typeLocations);
				} else {
					types.put(type, ArrayExt.insertAt(typeLocations, location, typeLocations.size()));
				}
				typeLocations = null;
			}
			locations = null;
			var keys = types.keys();
			var values = types.values();
			types = null;
			var indexes = new[keys.size()];
			for(var i = 0; i < indexes.size(); i++){
				indexes[i] = [i, keys[i]];
			}
			keys = null;
			indexes = ArrayExt.sort(indexes, method(:numberComparer)); 
			values = ArrayExt.sortByIndex(values, indexes, method(:indexGetter));
			indexes = null;
			return ArrayExt.insertAt(values, all, 0);
		}
		
		// batches
		
		function getBatches(){
			return new Batches(getProp(BATCH_ID), getProp(BATCH_NAME), getProp(BATCH_DATE));
		}
		
		hidden function setBatches(batches){
			setProp(BATCH_ID, batches.ids);
			setProp(BATCH_NAME, batches.names);
			setProp(BATCH_DATE, batches.dates);
		}
		
		function getBatchesList(){ // return just names and indexes
			var batches = getBatches();
			var batchesList = new[batches.ids.size()];
			for(var i = 0; i < batches.ids.size(); i++){
				batchesList[i] = [i, batches.ids[i], batches.names[i], batches.dates[i]];
			}
			return batchesList;
		}
		
		// show error if too much
		function addLocations(newLocations){
			var locations = getLocations();
			locations.names = ArrayExt.union(locations.names, newLocations.names);
			locations.latitudes = ArrayExt.union(locations.latitudes, newLocations.latitudes);
			locations.longitudes = ArrayExt.union(locations.longitudes, newLocations.longitudes);
			locations.types = ArrayExt.union(locations.types, newLocations.types);
			locations.batches = ArrayExt.union(locations.batches, newLocations.batches);
			locations = sortLocations(locations, getSortBy());
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
		
		// sorting
		
		function sortLocations(locations, sortBy){
			var method = null;
			var arrayToSort = null;
			if(sortBy == SORTBY_NAME || currentLocation == null){
				method = method(:nameComparer);
				arrayToSort = locations.names;
			} else if(sortBy == SORTBY_DISTANCE){
				method = method(:numberComparer);
				arrayToSort = new[locations.latitudes.size()];
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
		
		function nameComparer(a, b){
			var h1 = a[1].substring(0, 2).hashCode();
			var h2 = b[1].substring(0, 2).hashCode();
			return h1 - h2;
		}
		
		function numberComparer(a, b){
			return a[1] - b[1];
		}
		
		function indexGetter(index){
			return index[0];
		}
		
		function find(str){
		}
		
		// deleting
		
		function deleteBatch(i){
		}
		
		function deleteLocation(i){
		}
		
		// persisted
		
		function saveLocationPersisted(i){
		}
		
		function saveBatchPersisted(i){
		}
	}
	
	const r = 6371;
	function distance(lat1, lon1, lat2, lon2){ // return in san
		var dLat = lat2 - lat1;
		var dLon = lon2 - lon1;
		var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
		        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
		return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	}
		
	class Location {
		var name;
		var latitude;
		var longitude;
		var type;
		var batch;
		
		function initialize(_name, _latitude, _longitude, _type, _batch){
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
		
		function get(i){
			return new Location(names[i], latitudes[i], longitudes[i], types[i], batches[i]);
		}
		
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
		
		function toString(loc){
			var str = "";
			if(loc != null){
				for(var i = 0; i < size(); i++){
					str = str + names[i] + " " + latitudes[i] + " " + longitudes[i] + " " + types[i] + " " + batches[i] + " " + distance(latitudes[i], longitudes[i], loc[0], loc[1]) + "\n";
				}
			} else {
				for(var i = 0; i < size(); i++){
					str = str + names[i] + " " + latitudes[i] + " " + longitudes[i] + " " + types[i] + " " + batches[i] + "\n";
				}
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
		
		function get(i){
			return new Batch(ids[i], names[i], dates[i]);
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