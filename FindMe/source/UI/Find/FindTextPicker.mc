using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class FindTextPicker extends Ui.TextPicker{
		function initialize(){
			
		}
	}
	
	class FindTextPickerDelegate extends Ui.TextPickerDelegate {
		function initialize(){
		}
		
		function onTextEntered(search, changed){
			var locations = dataStorage.find(search);
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