using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Position;
using Toybox.Lang;
using Data;

module UI{
	class NamePicker extends Ui.Picker{
		function initialize(def){
			var pattern = new[Data.NAME_LIMIT];
			for(var i = 0; i < Data.NAME_LIMIT; i++){
				pattern[i] = new CharFactory();
			}
			var defaults = null;
			if(def != null){
				defaults = new[Data.NAME_LIMIT];
				for(var i = 0; i < def.length(); i++){
					var c = def.substring(i, i + 1);
					var index = CharFactory.values.find(c);
					defaults[i] = index;
				}
			}
			setOptions({
				:title => getText("Name", {:isTitle => true}), 
				:pattern => pattern,
				:defaults => defaults
			});
		}
		
		function onUpdate(dc) {
	        clearPicker(dc);
	    }
	}
	
	class NamePickerDelegate extends Ui.PickerDelegate {
		hidden var locationStr;
		hidden var format;
	
		function initialize(_locationStr, _format){
			locationStr = _locationStr;
			format = _format;
		}
		
		function onAccept(values){
			var name = "";
			var trim = false;
			for(var i = 0; i < values.size(); i++){
				if(!values[i].equals(" ") || trim){
					name = name + values[i];
					trim = true;
				}
			}
			for(trim = name.length() - 1; trim >= 0; trim--){
				if(!name.substring(trim, trim + 1).equals(" ")){
					break;
				}
			}
			name = name.substring(0, trim + 1);
			if(name.length() > 0){
				Ui.pushView(new NewTypesMenu(), new NewTypesMenuDelegate(locationStr, name, format), transition);
				pushInfoView("Name: " + name, null, false);
			} else {
				pushInfoView("Name can't be empty", null, false);
			}
		}
	}
}