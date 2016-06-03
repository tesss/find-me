using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Data;

module UI {
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
	
	class NumberFactory extends Ui.PickerFactory {
		var limit;
		function initialize(_limit){
			if(_limit == null){
				limit = 10;
			} else {
				limit = _limit;
			}
		}
	
		function getDrawable(index, isSelected){ return getText(getValue(index).toString(), {:isNumber => true, :isSelected => isSelected}); }
		function getSize(){ return limit; }
		function getValue(index){ return index; }
	}
	
	class CharFactory extends Ui.PickerFactory {
		static const values = " ~}|{_^]\\[@?>=<;:/.-,+*)('&%$#\"!0987654321zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA";
		function getDrawable(index, isSelected){ return getText(getValue(index), {:isSelected => isSelected}); }
		function getSize(){ return values.length(); }
		function getValue(index){ return values.substring(index, index + 1); }
	}
}