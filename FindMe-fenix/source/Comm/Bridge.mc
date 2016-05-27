using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Math;
using Data;
using _;

module Comm {
	class Bridge {
		function initialize(){
	        Comm.setMailboxListener( method(:onMail) );
	    }
	    
	    function parseMail(mail){
	    	// mock
	    	var batch = [mail, "Batch #" + mail, Time.now().value()];
	    	var l = 10;
	    	var locations = new Data.Locations(new[l],new[l],new[l],new[l],new[l]);
	    	for(var i = 0; i < l; i++){
	    		if(i < 10){
	    			locations.names[i] = "IIEiger Wall 0" + i;
	    		} else {
	    			locations.names[i] = "IIEiger Wall " + i;
	    		}
	    		
	    		locations.latitudes[i] = (Math.rand() % 150) * 0.01;
	    		locations.longitudes[i] = (Math.rand() % 314) * 0.01;
	    		locations.types[i] = Math.rand() % Data.DataStorage.TYPES.size();
	    		locations.batches[i] = mail;
	    	}
	    	locations.set(0, "Franka", 0.8698, 0.4192, 0, null);
	    	locations.set(1, "Shevshenka 36", 0.869790, 0.419443518, 0, null);
	    	locations.set(2, "Hrushevsky", 0.869793, 0.419437057, 0, null);
	    	locations.set(3, "Tram Stop", 0.869768, 0.4194759129, 0, null);
	    	
	    	return [batch, locations];
	    }
	    
	    function onMail(mailIter)
	    {
	        var mail = mailIter.next();
	        while( mail != null )
	        {
	            mail = mailIter.next();
	            var batch = parseBatch(mail);
	            dataStorage.addBatch(batch);
	        }
	        Comm.emptyMailbox();
	    }
	}
}