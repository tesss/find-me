using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Position;
using Toybox.Lang;
using Data;

module UI{
	class FindPicker extends Ui.Picker{
		function initialize(){
			var pattern = new[Data.FIND_LIMIT];
			for(var i = 0; i < Data.FIND_LIMIT; i++){
				pattern[i] = new CharFactory(true);
			}
			setOptions({
				:title => getText("Find", {:isTitle => true}), 
				:pattern => pattern
			});
		}
	}
	
	class FindPickerDelegate extends Ui.PickerDelegate {
		function initialize(){
		}
		
		function onAccept(values){
			var search = "";
			var trim = false;
			for(var i = 0; i < values.size(); i++){
				if(!values[i].equals(" ") || trim){
					search = search + values[i];
					trim = true;
				}
			}
			for(trim = search.length() - 1; trim >= 0; trim--){
				if(!search.substring(trim, trim + 1).equals(" ")){
					break;
				}
			}
			search = search.substring(0, trim + 1);
			var locations = dataStorage.find(search);
			Ui.popView(noTransition);
			if(locations.size() == 0){
				pushInfoView("No results", transition, false);
			} else {
				var model = new TypesViewModel([locations], false);
				Ui.pushView(new LocationView(model.get()), new LocationDelegate(model), transition);
			}
		}
		
		function onCancel(){
		}
	}
}