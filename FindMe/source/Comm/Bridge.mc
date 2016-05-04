using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Math;
using Data;
using _;

module Comm {
	class Bridge {
		function initialize()
	    {
	        Comm.setMailboxListener( method(:onMail) );
	    }
	    
	    function parseMail(mail){
	    	// mock
	    	var batch = new Data.Batch(mail, "Test Batch #" + mail, Time.now().value());
	    	var l = 100;
	    	var locations = new Data.Locations(new[l],new[l],new[l],new[l],new[l]);
	    	var types = ["city", "lake", "river", "mountain", "spring", "bus_station"];
	    	for(var i = 0; i < l; i++){
	    		locations.names[i] = "Location #" + i;
	    		locations.latitudes[i] = Math.rand() % 90;
	    		locations.longitudes[i] = Math.rand() % 180;
	    		locations.types[i] = Math.rand() % Data.DataStorage.types.size();
	    		locations.batches[i] = mail;
	    	}
	    	return [batch, locations];
	    }
	    
	    function onMail(mailIter)
	    {
	        var mail = mailIter.next();
	        while( mail != null )
	        {
	            mail = mailIter.next();
	            var batch = parseBatch(mail);
	            Data.DataStorage.addBatch(batch);
	        }
	        Comm.emptyMailbox();
	    }
	}
}