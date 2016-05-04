using Toybox.System;
using Toybox.Application;
using _;

module Data{
	class DataStorage {
		hidden const BATCH_KEY = 1;
		hidden const SORT_KEY = 2;
		hidden const DISTANCE_KEY = 3;

		var batches = null;
		var sortBy = null;
		var distance = null;
		var currentLocation = null;
		var app = null;
		
		function initialize(){
			app = Application.getApp().weak();
			if(loadBatches() == null){
				saveBatches(new Batches());
			}
			if(loadSortBy() == null){
				saveSortBy(Locations.SORTBY_DISTANCE);
			}
			if(loadDistance() == null){
				saveDistance(0);
			}
		}
		
		function getApp(){
			return app.get();
		}
		
		function getBatches(){
			return new Batches(List.fromArray(batches));
		}
		
		function setBatches(_batches){
			if(_batches == null){
				batches = null;
			}
			batches = _batches.list.toArray();
		}
		
		// settings
		
		function loadSortBy(){
			sortBy = getApp().getProperty(SORT_KEY);
			return sortBy;
		}
		
		function loadDistance(){
			distance = getApp().getProperty(DISTANCE_KEY);
			return distance;
		}
		
		function saveSortBy(sortBy){
			getApp().setProperty(SORT_KEY, sortBy);
			loadSortBy();
		}
		
		function saveDistance(distance){
			getApp().setProperty(DISTANCE_KEY, distance);
			loadDistance();
		}
			
		// locations
			
		function getLocations(all){
			var locations = new Locations();
			var batches = getBatches();
			var batch = batches.list.first;
			while(batch != null){
				var location = batch.value.locations.list.first;
				while(location != null){
					locations.list.add(location.value);
					location = location.getNext();
				}
				batch = batch.getNext();
			}
			locations = locations.sort(sortBy);
			if(!all){
				locations = locations.filter(distance);
			}
			return locations;
		}
		
		// batches
		
		function saveBatches(_batches){
			if(_batches != null){
				setBatches(_batches);
			}
			var batches = getBatches();
			batches = batches.sort();
			getApp().setProperty(BATCH_KEY, batches.toString());
			_.p(batches.toString());
			setBatches(batches);
		}
		
		function addBatch(batch){
			var batches = getBatches(); // load by request
			batches.list.add(batch); // insert into appropriate place without sorting
			saveBatches(batches);
		}
		
		function loadBatches(){
			var batches = getBatches();
			if(batches == null){
				Batches.fromString(getApp().getProperty(BATCH_KEY));
				setBatches(null);// parse
				return batches;
			}
			return batches;
		}
		
		function deleteBatch(){
			saveBatches(getBatches().delete(batch));
		}
	}
}