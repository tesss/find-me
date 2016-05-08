using Data;

module UI{
	class LocationsViewModel{
		hidden var locations;
		hidden var index;
		hidden var dataStorage;
		
		var animNext;
		
		function initialize(_locations, _dataStorage){
			locations = _locations;
			dataStorage = _dataStorage;
			index = 0;
			animNext = true;
		}
		
		function get(){
			return locations[index];
		}
		
		function next(){
			index++;
			if(index == locations.size()){
				index = 0;
			}
			animNext = true;
		}
		
		function prev(){
			index--;
			if(index == -1){
				index = locations.size() - 1;
			}
			animNext = false;
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