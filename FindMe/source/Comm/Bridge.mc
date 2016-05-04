using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time as Time;
using Data;
using _;

module Comm {
	class Bridge {
		function initialize()
	    {
	        Comm.setMailboxListener( method(:onMail) );
	    }
	    
	    function parseBatch(mail){
	    	// mock
	    	var batch = new Data.Batch("Test Batch " + mail, Time.now());
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	batch.locations.list.add(new Data.Location("Loc1", "City", 37.6, 50, 0));
	    	batch.locations.list.add(new Data.Location("Loc12", "Forest", 10, 60, 1000));
	    	batch.locations.list.add(new Data.Location("Loc13", "Mountain", -20, -10, 8000));
	    	
	    	return batch;
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