using Toybox.Math;
using Toybox.Time;
using _;

module Data {
	const VERSION = "0.1.0";
	const NAME_LIMIT = 15;
	const ZERO_LIMIT = 0.02;
	const LOC_MAX_COUNT = 100;
	const SPEED_LIMIT = 2;
	
	function toRadians(degrees){
		return degrees * Math.PI / 180;
	}
	
	function toDegrees(radians){
		return radians * 180 / Math.PI;
	}
	
	function atan2(y, x){
		if(x > 0){
			return Math.atan(y / x);
		}
		if(y > 0){
			return Math.PI / 2 - Math.atan(x / y);
		}
		if(y < 0){
			return -Math.PI / 2 - Math.atan(x / y);
		}
		if(x < 0){
			var pi = Math.PI;
			if(y < 0){
				pi = -p;
			}
			return atan(y / x)  + pi;
		}
		return null;
	}
	
	function distance(lat1, lon1, lat2, lon2){
		var dLat = lat2 - lat1;
		var dLon = lon2 - lon1;
		var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
		        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
		return 12742 * atan2(Math.sqrt(a), Math.sqrt(1-a));
	}
	
	function bearing(lat1, lon1, lat2, lon2){
		var dLon = lon2 - lon1;
		var y = Math.sin(dLon) * Math.cos(lat2);
		var x = Math.cos(lat1) * Math.sin(lat2) - 
				Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
		return atan2(y, x);
	}
	
	function heading(info){
		if(info == null){
			return null;
		}
		return info.heading;
		//var axf = toRadians(info.accel[0]);
		//var ayf = toRadians(info.accel[1]);
		//var mx = toRadians(info.mag[0]);
		//var my = toRadians(info.mag[1]);
		//var mz = toRadians(info.mag[2]);
		//var xh = mx * Math.cos(ayf) + my * Math.sin(ayf) * Math.sin(axf) - mz * Math.cos(axf) * Math.sin(ayf);
		//var yh = my * Math.cos(axf) + mz * Math.sin(axf);
	    //var h = atan2(yh, xh) - toRadians(90);
		//var r360 = toRadians(360);
		//if (h > 0){
		//	h -= r360;
		//}
		//h = h + r360;
		//return h;
	}
	
	function dateStr(moment){
		if(moment == null){
			moment = Time.Time.now().value();
		}
		var date = Time.Gregorian.info(new Time.Moment(moment), Time.FORMAT_SHORT);
		var dateStr = (date.year - 2000).format("%02d") + date.month.format("%02d") + date.day.format("%02d") + date.hour.format("%02d") + date.min.format("%02d");
		return dateStr;
	}
	
	enum {
		SORTBY_NAME,
		SORTBY_DISTANCE
	}
	
	enum {
		LAT,
		LON,
		HEADING,
		ACCURACY
	}
	
	enum {
		KEY_SORT,
		KEY_DISTANCE,
		KEY_INTERVAL,
		KEY_FORMAT,
		KEY_ACT_TYPE,
		
		KEY_LOC_LAT,
		KEY_LOC_LON,
		KEY_LOC_NAME,
		KEY_LOC_TYPE
	}
	
	enum {
		LOC_ID,
		LOC_NAME,
		LOC_LAT,
		LOC_LON,
		LOC_TYPE,
		LOC_DIST
	}
}