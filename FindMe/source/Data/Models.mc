module Data {
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
		
		function get(i, lat, lon){
			if(lat != null && lon != null){
				return [i, names[i], latitudes[i], longitudes[i], types[i], batches[i], distance(latitudes[i], longitudes[i], lat, lon)];
			}
			return [i, names[i], latitudes[i], longitudes[i], types[i], batches[i]];
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
			return [i, ids[i], names[i], dates[i]];
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
}