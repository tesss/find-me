using Toybox.Position as Pos;
using _;

module Data{
	var currentLocation;
	function updateCurrentLocation(){ // update in timer
		currentLocation = Pos.getInfo();
	}
}