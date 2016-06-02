using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class BatchMenu extends Ui.Menu {
		function initialize(batch){
			setTitle(batch[Data.BATCH_NAME]);
			addItem("Delete", :delete);
		}
	}
	
	class BatchMenuDelegate extends Ui.MenuInputDelegate {
		hidden var batch;
		
		function initialize(_batch){
			batch = _batch;
		}
		
		function onMenuItem(symbol){
			var id = batch[Data.BATCH_ID];
			if(symbol == :delete) {
				dataStorage.deleteBatch(id);
				Ui.popView(transition);
				openMainMenu = false;
				openBatchesMenu = true;
				pushInfoView("Deleted", true);
			}
		}
	}
}