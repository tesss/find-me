using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Lang as Lang;
using Toybox.Math;
using Toybox.Position;
using _;

module Data {
	class Location {
		const r = 6371000;
		
		var name;
		var type;
		var latitude; // in radians
		var longitude; // in radians
		var attitude;
		
		function initialize(_name, _type, _latitude, _longitude, _attitude){
			name = _name;
			type = _type;
			latitude = _latitude;
			longitude = _longitude;
			attitude = _attitude;
		}
		
		function distance(location){
			if(location.accuracy == Position.QUALITY_NOT_AVAILABLE){
				return 0;
			}
			var pos = location.position.toRadians();
			
			var lat1 = Math.toRadians(latitude);
			var lat2 = pos[0];
			var lon1 = Math.toRadians(longitude);
			var lon2 = pos[1];
			
			_.p("lat1:" + lat1 + " lat2:" + lat2 + " lon1:" + lon1 + " lon2:" + lon2);
			_.p(location.position.toGeoString(Position.GEO_DM));
			
			var f1 = lat1;
			var f2 = pos[0];
			var df = Math.toRadians((lat2 - lat1));
			var dy = Math.toRadians((lon2 - lon1));
			
			var a = Math.sin(df/2)*Math.sin(df/2) + Math.cos(f1)*Math.cos(f2)*Math.sin(dy/2)*Math.sin(dy/2);
			var c = 2 * Math.atan(Math.sqrt(a), Math.sqrt(1-a));
			var d = r * c;
			_.p("D:" + d);
			return d;
		}
	}
}