using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Data;

module UI{
	class LocationPicker extends Ui.Picker {
		var format;
		const FONT = Graphics.FONT_SMALL;
		const JUSTIFICATION = Graphics.TEXT_JUSTIFY_CENTER;
	
		function initialize(_format){
			format = _format;
			var separator = new Ui.Text({
				:text => "-",
				:font => FONT, 
				:justification => JUSTIFICATION
			});
			setOptions({
				:title => new Ui.Text({
					:text => "Add Location",
					:font => FONT, 
					:justification => JUSTIFICATION
				}), 
				:pattern => [separator]
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
				:font => Graphics.FONT_SMALL, 
				:justification => Graphics.TEXT_JUSTIFY_CENTER
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