using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time as Time;
using Data;
using _;

module Comm{
	class CommListener extends Comm.ConnectionListener {
	    function onComplete(){
	        System.println( "Transmit Complete" );
	    }
	
	    function onError(){
	        System.println( "Transmit Failed" );
	    }
	}
}