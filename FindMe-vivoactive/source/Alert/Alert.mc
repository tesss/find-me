using Toybox.Attention;

module Alert{
	enum {
		GPS_FOUND,
		GPS_LOST,
		GPS_MANUAL,
		ACTIVITY_START,
		ACTIVITY_SAVE,
		ACTIVITY_DISCARD,
		ACTIVITY_FAILURE,
		ZERO_DISTANCE,
		ERROR
	}
	
	hidden function vibrate(){
		Attention.vibrate([new Attention.VibeProfile(50, 500)]);
	}

	function alert(event){ 
		vibrate();
	}
}