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
		if(event == ACTIVITY_START){
			Attention.playTone(Attention.TONE_START);
		} else if(event == ACTIVITY_SAVE){
			Attention.playTone(Attention.TONE_STOP);
		} else if(event == ACTIVITY_DISCARD){
			Attention.playTone(Attention.TONE_STOP);
		} else if(event == ACTIVITY_FAILURE){
			Attention.playTone(Attention.TONE_ERROR);
		} 
	}
}