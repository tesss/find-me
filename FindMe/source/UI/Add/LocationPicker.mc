using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Data;

module UI{
	const PICKER_FONT = 6;
	const PICKER_JUSTIFICATION = 2;

	class LocationPicker extends Ui.Picker {
		var format;
	
		function initialize(_format){
			format = _format;
			var separator = new Ui.Text({
				:text => "-",
				:font => PICKER_FONT
				//:justification => PICKER_JUSTIFICATION
			});
			setOptions({
				:title => new Ui.Text({
					:text => "New",
					:font => Graphics.FONT_MEDIUM,
					:justification => Graphics.TEXT_JUSTIFY_LEFT
				}), 
				:pattern => [new DegreeFactory(true), separator, new DegreeFactory(false)]
			});
		}
	}
	
	class DegreeFactory extends Ui.PickerFactory {
		var isLat;
		
		function initialize(_isLat){
			isLat = _isLat;
		}
		
		function getDrawable(index, isSelected){
			var color = COLOR_PRIMARY;
			if(isSelected){
				color = COLOR_SECONDARY;
			}
			return new Ui.Text({
				:text => index.toString(),
				:color => color, 
				:font => PICKER_FONT,
				:justification => PICKER_JUSTIFICATION
			});
		}
		
		function getSize(){
			if(isLat){
				return 91;
			}
			return 181;
		}
		
		function getValue(index){
			return index;
		}
	}
	
	class LocationPickerDelegate extends Ui.PickerDelegate{
		function onAccept(values){
		}
		
		function onCancel(){
		}
	}
}