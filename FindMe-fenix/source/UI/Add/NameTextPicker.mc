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
				name = name.substring(0, 15);
			}
			keepMainView = true;
			Ui.pushView(new NewTypesMenu(), new NewTypesMenuDelegate(locationStr, name, format), transition);
		}
	}
}