using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class NameTextPickerDelegate extends Ui.TextPickerDelegate {
		hidden var locationStr;
		hidden var format;
		hidden var back;
	
		function initialize(_locationStr, _format, _back){
			locationStr = _locationStr;
			format = _format;
			back = _back;
		}
		
		function onTextEntered(name, changed){
			if(name.length() > 15){
				pushInfoView("Max length 15", transition, false);
			} else {
				Ui.pushView(new NewTypesMenu(), new NewTypesMenuDelegate(locationStr, name, format, true, back), transition);
			//pushInfoView("Name: " + name, null, false);
			}
		}
		
		function onCancel(){
			if(back){
				Ui.pushView(new LocationPicker(format), new LocationPickerDelegate(format), transition);
			}
		}
	}
}