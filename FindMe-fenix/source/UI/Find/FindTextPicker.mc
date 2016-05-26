using Toybox.WatchUi as Ui;
using Toybox.Position;
using Data;
using _;

module UI{
	class FindTextPickerDelegate extends Ui.TextPickerDelegate {
		function onTextEntered(search, changed){
			if(search.length() > 15){
				pushInfoView("Max length 15", transition, false);
			} else {
				var locations = dataStorage.find(search);
				if(locations.size() == 0){
					pushInfoView("No results", transition, false);
				} else {
					var model = new TypesViewModel([locations], false);
					Ui.pushView(new LocationView(model.get()), new LocationDelegate(model), transition);
				}
			}
		}
	}
}