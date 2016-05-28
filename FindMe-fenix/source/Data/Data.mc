using Toybox.Math;
using Toybox.Time;
using _;

module Data {
	const NAME_LIMIT = 15;
	const ZERO_LIMIT = 0.005;
	
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
	
	function dateStr(moment){
		var date = Time.Gregorian.info(new Time.Moment(moment), Time.FORMAT_SHORT);
		var dateStr = date.day + "." + date.month + "." + date.year + " " + date.hour + ":" + date.min + ":" + date.sec;
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
		KEY_LOC_TYPE,
		KEY_LOC_BATCH,
		
		KEY_BATCH_ID,
		KEY_BATCH_NAME,
		KEY_BATCH_DATE
	}
	
	enum {
		KEY,
		VALUE
	}
	
	enum {
		LOC_ID,
		LOC_NAME,
		LOC_LAT,
		LOC_LON,
		LOC_TYPE,
		LOC_BATCH,
		LOC_DIST
	}
	
	enum {
		BATCH_ID,
		BATCH_NAME,
		BATCH_DATE
	}
}