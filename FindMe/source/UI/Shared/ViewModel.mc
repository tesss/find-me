using Toybox.WatchUi as Ui;
using Data;

module UI{
	class TypesViewModel{
		var types;
		var index;
		var global;
		
		function initialize(_types, _global){
			global = _global;
			types = new[_types.size()];
			for(var i = 0; i < types.size(); i++){
				types[i] = new LocationsViewModel(_types[i]);
			}
		}
		
		function size(){
			return types.size();
		}
		
		function get(i){
			if(i != null){
				return types[i];
			}
			return types[index];
		}
		
		function getTypeName(i){
			if(i == 0){
     			return "All";
	    	} else {
	    		var key = get(i).get(0)[Data.LOC_TYPE];
	    		return Data.DataStorage.TYPES[key];
	    	}
		}
		
		function delete(){
			var locationsModel = get();
			var locationIndex = locationsModel.index;
			var currentId = locationsModel.get()[Data.DataStorage.LOC_ID];
			dataStorage.deleteLocation(currentId);
			locationsModel.locations = Data.ArrayExt.removeAt(locationsModel.locations, locationIndex);
			if(!global){
				return false;
			}
			
			var all = get(0);
			for(var i = 0; i < all.size(); i++){
				var location = all.get(i);
				var id = location[Data.DataStorage.LOC_ID];
				if(index != 0 && id == currentId){
					all.locations = Data.ArrayExt.removeAt(all.locations, i);
					i--;
				} else if(id > currentId){
					location[Data.DataStorage.LOC_ID]--;
				}
			}
			if(index == 0){
				var removed = false;
				for(var i = 1; i < size(); i++){
					if(removed){
						break;
					}
					var locations = get(i);
					for(var j = 0; j < locations.size(); j++){
						var location = locations.get(j);
						var id = location[Data.DataStorage.LOC_ID];
						if(id == currentId){
							locations.locations = Data.ArrayExt.removeAt(locations.locations, j);
							removed = true;
						}
					}
				}
			}
			
			if(locationsModel.size() == 0){
				return true;
			}
			return false;
		}
		
		function dispose(){
			if(types != null){
				for(var i = 0; i < types.size(); i++){
					for(var j = 0; j < types[i].locations.size(); j++){
						types[i].locations[j][Data.LOC_ID] = null;
						types[i].locations[j][Data.LOC_NAME] = null;
						types[i].locations[j][Data.LOC_LAT] = null;
						types[i].locations[j][Data.LOC_LON] = null;
						types[i].locations[j][Data.LOC_TYPE] = null;
						types[i].locations[j][Data.LOC_BATCH] = null;
						types[i].locations[j][Data.LOC_DIST] = null;
						types[i].locations[j] = null;
					}
					types[i].locations = null;
					types[i] = null;
				}
				types = null;
			}
		}
	}

	class LocationsViewModel{
		var locations;
		var index;
		var fullRefresh;
		
		function initialize(_locations){
			locations = _locations;
			index = 0;
			fullRefresh = true;
		}
		
		function size(){
			return locations.size();
		}
		
		function get(i){
			if(i == null){
				i = index;
			}
			if(i < 0 || i >= size()){
				return null;
			}
			return locations[i];
		}
		
		function next(){
			index++;
			if(index == locations.size()){
				index = 0;
			}
			fullRefresh = true;
		}
		
		function prev(){
			index--;
			if(index == -1){
				index = locations.size() - 1;
			}
			fullRefresh = true;
		}
		
		function showArrows(){
			return locations.size() > 1;
		}
		
		function sort(){
			var sorted = dataStorage.sortLocationsList(locations, get()[Data.LOC_ID]);
			locations = sorted[0];
			index = sorted[1];
		}
	}
}