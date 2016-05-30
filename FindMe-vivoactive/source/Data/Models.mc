module Data {
	class Locations {
		var names;
		var latitudes;
		var longitudes;
		var types;
		var batches;
		
		function get(i, lat, lon){
			var distance = null;
			if(lat != null && lon != null){
				distance = distance(latitudes[i], longitudes[i], lat, lon);
			}
			return [i, names[i], latitudes[i], longitudes[i], types[i], batches[i], distance];
		}
		
		function set(i, name, latitude, longitude, type, batch){
			names[i] = name;
			latitudes[i] = latitude;
			longitudes[i] = longitude;
			types[i] = type;
			batches[i] = batch;
		}
		
		function remove(i){
			if(i < 0 || i >= size()){
				return;
			}
			names = ArrayExt.removeAt(names, i);
			latitudes = ArrayExt.removeAt(latitudes, i);
			longitudes = ArrayExt.removeAt(longitudes, i);
			types = ArrayExt.removeAt(types, i);
			batches = ArrayExt.removeAt(batches, i);
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
			return [ids[i], names[i], dates[i]];
		}
		
		function set(i, id, name, date){
			ids[i] = id;
			names[i] = name;
			dates[i] = date;
		}
		
		function remove(i){
			if(i < 0 || i >= size()){
				return;
			}
			ids = ArrayExt.removeAt(ids, i);
			names = ArrayExt.removeAt(names, i);
			dates = ArrayExt.removeAt(dates, i);
		}
		
		function size(){
			if(ids == null){
				return 0;
			}
			return ids.size();
		}
	}
}