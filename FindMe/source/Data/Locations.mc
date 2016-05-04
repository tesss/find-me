using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Lang as Lang;
using _;

module Data {
	class Locations { // ingerit from list
		const TYPE_ALL = "all";
	
		var list;
		
		hidden var distance;
		hidden var searchString;
		
		function initialize(_list){
			if(_list == null){
				list = new List();
			} else {
				list = _list;
			}
		}
		
		function each(method){
			list.each(method);
		}
		
		function sort(sortBy){
			var result = list;
			if(sortBy == SORTBY_NAME){
				result = list.sort(method(:nameComparer));
			} else if(sortBy == SORTBY_TYPE){
				result = list.sort(method(:typeComparer));
			} else if(sortBy == SORTBY_DISTANCE){
				result = list.sort(method(:distanceComparer));
			}
			return new Locations(result);
		}
		
		function filter(_distance){ // optimise
			distance = _distance;
			var result = new Locations(list.filter(method(:distancePredicate)));
			distance = null;
			return result;
		}
		
		// get
		
		function getTypes(){
			var locations = filter(distance);
			var types = {};
			var item = locations.list.first;
			while(item){
				if(!types.hasKey(item.value.type)){
					types.put(item.type, new List());
				}
				types.get(item.type).add(item.value);
				item = item.getNext();
			}
			types.put(TYPE_ALL, locations);
			var typesArray = types.values();
			typesArray = ArrayExt.sort(typesArray, method(:typeDictComparer));
			return typesArray;
		}
		
		function find(name){
			searchString = name;
			var result = new Locations(list.filter(findPredicate));
			searchString = null;
			return result;
		}
		
		static function delete(value){
			list.remove(value);
		}
		
		// predicates
		
		hidden function nameComparer(a, b){
			return a.name.length() - b.name.length(); // implement comparing by string
		}
		
		hidden function typeComparer(a, b){
			if(a.type == b.type){
				return nameComparer(a, b);
			}
			return a.type > b.type;
		}
		
		function distanceComparer(a, b){
			var loc = currentLocation;
			var d1 = a.distance(loc);
			var d2 = b.distance(loc);
			if(d1 == d2){
				return nameComparer(a, b);
			}
			return d1 - d2;
		}
		
		function distancePredicate(item){
			return item.distance(currentLocation) <= distance;
		}
		
		function typeDictComparer(a, b){
			if(a[0].type == TYPE_ALL){
				return 1;
			}
			return a[0].type > b[0].type;
		}
		
		function findPredicate(a){
			return a.type.find(searchString) != null || a.name.find(searchString) != null;
		}
		
		function toString(){
			var str = "";
			var location = list.first;
			while(location != null){
				str = str + "[" + location.value.name + ",";
				str = str + location.value.type + ",";
				str = str + location.value.latitude + ",";
				str = str + location.value.longitude + ",";
				str = str + location.value.attitude + "]";
				location = location.getNext();
			}
			return str;
		}
	}
	
	enum {
		SORTBY_NAME,
		SORTBY_TYPE,
		SORTBY_DISTANCE
	}
}