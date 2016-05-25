using Toybox.WatchUi as Ui;
using Toybox.System;

module UI{
	var dataStorage;
	var transition;
	var screenType;
	var model;
	var openMainMenu;
	var openTypesMenu;
	var drawModel;
	
	const COLOR_BACKGROUND = 0x000000;
	const COLOR_PRIMARY = 0xFFFFFF;
	const COLOR_SECONDARY = 0xAAAAAA;
	const COLOR_LOWLIGHT = 0x555555;
	const COLOR_HIGHLIGHT = 0xFFAA00;
	
	function pushMainMenu(){
		Ui.pushView(new MainMenu(), new MainMenuDelegate(), transition);
	}
	
	function pushTypesMenu(){
		//release();
		if(model == null){
			var types = dataStorage.getTypesList();
			model = new TypesViewModel(types, true);
			types = null;
		}
		if(model.size() <= 1){
			pushInfoView("No locations", transition, false);
		} else {
			// delete/add/import into model
			Ui.pushView(new TypesMenu(model), new TypesMenuDelegate(model), transition);
		}
	}
	
	function pushInfoView(_str, _transition, _pop, _exit){
		if(_transition == null){
			_transition = transition;
		}
		_pop = _pop == null || _pop instanceof Lang.Method || _pop;
		_exit = _exit == true;
		Ui.pushView(new InfoView(_str), new InfoDelegate(_pop, _exit), _transition);
	}
	
	function pushNameView(location, format, back){
		if(Ui has :TextPicker){
			Ui.pushView(new NameTextPicker(), new NameTextPickerDelegate(location, format, back), transition);
		} else {
			Ui.pushView(new NamePicker(), new NamePickerDelegate(location, format, back), transition);
		}
	}
	
	function pushFindView(){
		if(Ui has :TextPicker){
			Ui.pushView(new FindTextPicker(), new FindTextPickerDelegate(), transition);
		} else {
			Ui.pushView(new FindPicker(), new FindPickerDelegate(), transition);
		}
	}
	
	function pushBatchesMenu(){
		release();
		var batches = dataStorage.getBatchesList();
		if(batches == null || batches.size() == 0) {
			pushInfoView("No batches", null, false);
		} else {
			Ui.pushView(new BatchesMenu(batches), new BatchesMenuDelegate(batches), transition);
		}
	}
	
	function getText(str, options){
		var text = new Ui.Text({
			:text => str, 
			:font => Graphics.FONT_MEDIUM, 
			:justification => Graphics.TEXT_JUSTIFY_CENTER,
			:color => COLOR_SECONDARY,
			:locX => Ui.LAYOUT_HALIGN_CENTER,
			:locY => Ui.LAYOUT_VALIGN_CENTER
		});
		if(options == null){
			
		} else {
			var isSelected = options.get(:isSelected) == true;
			var isNumber = options.get(:isNumber) == true;
			var isTitle = options.get(:isTitle) == true;
			var isSettings = options.get(:isSettings) == true;
			if(isSettings){
				text.setFont(Graphics.FONT_TINY);
				if(isSelected){
					text.setColor(COLOR_PRIMARY);
				} else {
					text.setColor(COLOR_SECONDARY);
				}
			} else {
				if(isNumber){
					if(isSelected){
						text.setFont(Graphics.FONT_NUMBER_MEDIUM);
					} else {
						text.setFont(Graphics.FONT_NUMBER_MILD);
					}
				} else {
					if(isSelected){
						text.setFont(Graphics.FONT_LARGE);
					}
				}
				if(isSelected){
					text.setColor(COLOR_PRIMARY);
				}
				if(isTitle){
					text.setLocation(Ui.LAYOUT_HALIGN_CENTER, Ui.LAYOUT_VALIGN_TOP);
					if(!isNumber){
						text.setFont(Graphics.FONT_SMALL);
					}
				}
			}
		}
		return text;
	}
	
	function release(){
		if(model != null){
			model.dispose();
			model = null;
		}
		drawModel = null;
	}
	
	function getMenuIndex(symbol, size){
		for(var i = 0; i < size; i++){
			if(symbol == i){
				return i;
			}
		}
		return null;
	}
	
	function clearPicker(dc){
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
	}
}