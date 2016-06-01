using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class NameTextPickerDelegate extends Ui.TextPickerDelegate {
		hidden var locationStr;
		hidden var format;
	
		function initialize(_locationStr, _format){
			locationStr = _locationStr;
			format = _format;
		}
		
		function onTextEntered(name, changed){
			if(name.length() > 15){
				pushInfoView("Max length 15", false, true);
			} else {
				keepMainView = true;
				Ui.pushView(new NewTypesMenu(), new NewTypesMenuDelegate(locationStr, name, format), transition);
			}
		}
	}
}