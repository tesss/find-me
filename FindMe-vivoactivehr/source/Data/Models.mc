module Data {
	class Locations {
		var names;
		var latitudes;
		var longitudes;
		var types;
		
		function get(i, lat, lon){
			var distance = null;
			if(lat != null && lon != null){
				distance = distance(latitudes[i], longitudes[i], lat, lon);
			}
			return [i, names[i], latitudes[i], longitudes[i], types[i], distance];
		}
		
		function set(i, name, latitude, longitude, type){
			names[i] = name;
			latitudes[i] = latitude;
			longitudes[i] = longitude;
			types[i] = type;
		}
		
		function remove(i){
			if(i < 0 || i >= size()){
				return;
			}
			names = ArrayExt.removeAt(names, i);
			latitudes = ArrayExt.removeAt(latitudes, i);
			longitudes = ArrayExt.removeAt(longitudes, i);
			types = ArrayExt.removeAt(types, i);
		}
		
		function size(){
			if(names == null){
				return 0;
			}
			return names.size();
		}
		
		function initialize(_names, _latitudes, _longitudes, _types){
			names = _names;
			latitudes = _latitudes;
			longitudes = _longitudes;
			types = _types;
		}
	}
}