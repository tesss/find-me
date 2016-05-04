using Toybox.System;
using Toybox.Lang as Lang;
using _;

module Data {
	class ListItem{
		var value;
		var next;
		
		function getNext(){
			return next;
		}
		
		function setNext(_next){
			next =_next;
		}
		
		function initialize(_value, _next){
			value = _value;
			setNext(_next);
		}
	}
}