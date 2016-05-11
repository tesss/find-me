using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Math;
using Data;
using _;

module Comm {
	class Bridge {
		hidden var dataStorage;
	
		function initialize(_dataStorage)
	    {
	    	dataStorage = _dataStorage;
	        Comm.setMailboxListener( method(:onMail) );
	    }
	    
	    function parseMail(mail){
	    	// mock
	    	var batch = [mail, "Batch #" + mail, Time.now().value()];
	    	var l = 20;
	    	var locations = new Data.DataStorage.Locations(new[l],new[l],new[l],new[l],new[l]);
	    	for(var i = 0; i < l; i++){
	    		locations.names[i] = "Brighton Beach " + i;
	    		locations.latitudes[i] = (Math.rand() % 150) * 0.01;
	    		locations.longitudes[i] = (Math.rand() % 314) * 0.01;
	    		locations.types[i] = Math.rand() % Data.DataStorage.TYPES.size();
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
	            dataStorage.addBatch(batch);
	        }
	        Comm.emptyMailbox();
	    }
	}
}