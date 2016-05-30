using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class BatchesMenu extends Ui.Menu {
		function initialize(batches){
			setTitle("Batches");
			for(var i = 0; i < batches.size(); i++){
				addItem(batches[i][Data.BATCH_NAME], i);
			}
		}
	}
	
	class BatchesMenuDelegate extends Ui.Menu {
		hidden var batches;
		
		function initialize(_batches){
			batches = _batches;
		}
		
		function onMenuItem(symbol){
			var index = getMenuIndex(symbol, batches.size());
			Ui.pushView(new BatchMenu(batches[index]), new BatchMenuDelegate(batches[index]), transition);
		}
	}
}