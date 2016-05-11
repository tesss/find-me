using Toybox.WatchUi as Ui;
using Data;

module UI{
	class TypesViewModel{
		var types;
		var index;
		var dataStorage;
		
		function initialize(_types, _dataStorage){
			types = new[_types.size()];
			for(var i = 0; i < types.size(); i++){
				types[i] = new LocationsViewModel(_types[i], _dataStorage);
			}
			dataStorage = _dataStorage;
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
			var currentId = locationsModel.get()[dataStorage.LOC_ID];
			dataStorage.deleteLocation(currentId);
			locationsModel.locations = Data.ArrayExt.removeAt(locationsModel.locations, locationIndex);
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
	}

	class LocationsViewModel{
		var locations;
		var index;
		var dataStorage;
		var fullRefresh;
		
		function initialize(_locations, _dataStorage){
			locations = _locations;
			dataStorage = _dataStorage;
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