using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Data;

module UI {
	class DegreeFactory extends Ui.PickerFactory {
		var isLat;		
		function initialize(_isLat){ isLat = _isLat; }
		function getDrawable(index, isSelected){ return getText(index.toString(), {:isNumber => true, :isSelected => isSelected});}
		function getSize(){ if(isLat){ return 91; } return 181; }
		function getValue(index){ return index; }
	}
	
	class DirectionFactory extends Ui.PickerFactory {
		var values;
		function initialize(_isLat){
			if(_isLat){
				values = ["N", "S"];
			} else {
				values = ["E", "W"];
			}
		}
		function getDrawable(index, isSelected){ return getText(getValue(index), {:isSelected => isSelected}); }
		function getSize(){ return values.size(); }
		function getValue(index){ return values[index]; }
	}
	
	class MinuteFactory extends Ui.PickerFactory {
		var isMinute;
		function initialize(_isMinute){ isMinute = _isMinute; }
		function getDrawable(index, isSelected){
			var sign = "'";
			if(!isMinute){
				sign = "''";
			}
			return getText(getValue(index).toString(), {:isNumber => true, :isSelected => isSelected}); 
		}
		function getSize(){ return 60; }
		function getValue(index){ return index; }
	}
	
	class NumberFactory extends Ui.PickerFactory {
		function getDrawable(index, isSelected){ return getText(getValue(index).toString(), {:isNumber => true, :isSelected => isSelected}); }
		function getSize(){ return 10; }
		function getValue(index){ return index; }
	}
	
	class CharFactory extends Ui.PickerFactory {
		static var letterValues = "AZYXWVUTSRQPONMLKJIHGFEDCB";
		static var fullValues = " ~}|{_^]\\[@?>=<;:/.-,+*)('&%$#\"!0987654321zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA";
		
		hidden var full;
		function initialize(_full){ full = _full; }
		function getDrawable(index, isSelected){ return getText(getValue(index), {:isSelected => isSelected}); }
		function getSize(){
			if(full){
				return fullValues.length();
			}
			return letterValues.length(); 
		}
		function getValue(index){
			if(full){
				return fullValues.substring(index, index + 1);
			}
			return letterValues.substring(index, index + 1);
		}
	}
}