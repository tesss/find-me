using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Lang as Lang;
using _;

module Data {
	class Batch {
		var name;
		var date;
		var locations;
		
		function initialize(_name, _date, _locations){
			name = _name;
			date = _date;
			if(_locations == null){
				locations = new Locations();
			} else {
				locations = _locations;
			}
		}
	}
}