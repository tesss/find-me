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
			Attention.playTone(Attention.TONE_START);
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_SAVE){
			Attention.playTone(Attention.TONE_STOP);
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_DISCARD){
			Attention.playTone(Attention.TONE_STOP);
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ACTIVITY_FAILURE){
			Attention.playTone(Attention.TONE_ERROR);
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ZERO_DISTANCE){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		} else if(event == ERROR){
			Attention.vibrate([new Attention.VibeProfile(duty, length)]);
		}  
	}
}