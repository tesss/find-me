using Toybox.WatchUi as Ui;
using Data;
using _;

module UI{
	class BatchMenu extends Ui.Menu {
		function initialize(batch){
			setTitle(batch[Data.BATCH_NAME]);
			addItem("Save Persisted", :persisted);
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
			if(symbol == :persisted){
				dataStorage.saveBatchPersisted(id);
				Ui.popView(transition);
				pushInfoView("Saved successfully", false);
			} else if(symbol == :delete) {
				dataStorage.deleteBatch(id);
				Ui.popView(transition);
				Ui.popView(transition);
				pushBatchesMenu();
			}
		}
	}
}