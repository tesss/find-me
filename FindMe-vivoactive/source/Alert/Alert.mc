using Toybox.Attention;

module Alert{
	enum {
		GPS_FOUND,
		GPS_LOST,
		ACTIVITY_START,
		ACTIVITY_SAVE,
		ACTIVITY_DISCARD,
		ACTIVITY_FAILURE,
		ZERO_DISTANCE,
		ERROR
	}

	function alert(event){
		var duty = 50;
		var length = 500;
		if(event == GPS_FOUND){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == GPS_LOST){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_START){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_SAVE){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_DISCARD){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_FAILURE){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ZERO_DISTANCE){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ERROR){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		}  
	}
}