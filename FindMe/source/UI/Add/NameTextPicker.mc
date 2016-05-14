using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class NameTextPicker extends Ui.TextPicker{
		function initialize(){
			
		}
	}
	
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
			Ui.pushView(new NewTypesMenu(), new NewTypesMenuDelegate(locationStr, name, format, true, back), transition);
			//pushInfoView("Name: " + name, null, false);
		}
		
		function onCancel(){
			if(back){
				Ui.pushView(new LocationPicker(format), new LocationPickerDelegate(format), transition);
			}
		}
	}
}