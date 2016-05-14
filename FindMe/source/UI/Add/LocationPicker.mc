using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Position;
using Toybox.Lang;
using Data;

module UI{
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
		return text;
	}
	
	// 4QFJ12345678
	class LocationPicker extends Ui.Picker {
		function initialize(_format){
			var pattern = null;
			var title = null;
			if(_format == Position.GEO_DEG){
				title = "DD.DDDDDD";
				pattern = [
					new DirectionFactory(true), 
					new DegreeFactory(true), 
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					getText(" "),
					
					new DirectionFactory(false), 
					new DegreeFactory(false), 
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory()
				];
			} else if(_format == Position.GEO_DM){
				title = "DD MM.MMM'";
				pattern = [
					new DirectionFactory(true),
					new DegreeFactory(true),
					getText(" "),
					new MinuteFactory(true),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					getText("'"),
					getText(" "),
					
					new DirectionFactory(false),
					new DegreeFactory(false),
					getText(" "),
					new MinuteFactory(true),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					getText("'")
				];
			} else if(_format == Position.GEO_DMS){
				title = "DD MM' SS\"";
				pattern = [
					new DirectionFactory(true),
					new DegreeFactory(true),
					getText(" "),
					new MinuteFactory(true),
					getText("'"),
					getText(" "),
					new MinuteFactory(false),
					getText("\""),
					getText(" "),
					
					new DirectionFactory(false),
					new DegreeFactory(false),
					getText(" "),
					new MinuteFactory(true),
					getText("'"),
					getText(" "),
					new MinuteFactory(false),
					getText("\"")
				];
			} else if(_format == Position.GEO_MGRS){
				title = "MGRS";
				pattern = [
					new CharFactory(false),
					new CharFactory(false),
					new CharFactory(false),
					new CharFactory(false),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory()
				];
			}
			
			setOptions({
				:title => getText(title, {:isTitle => true}), 
				:pattern => pattern
			});
		}
	}
	
	class LocationPickerDelegate extends Ui.PickerDelegate{
		var format;
	
		function initialize(_format){
			format = _format;
		}
	
		function onAccept(values){
			var str = null;
			if(format == Position.GEO_DEG){
				str = values[0] + values[1] + "." + values[3] + values[4] + values[5] + values[6] + values[7] + values[8] + " " +
					  values[10] + values[11] + "." + values[13] + values[14] + values[15] + values[16] + values[17] + values[18];
			} else if(format == Position.GEO_DM){
				str = values[0] + values[1] + " " + values[3] + "." + values[5] + values[6] + values[7]  + "' " +
					  values[10] + values[11] + " " + values[13] + "." + values[15] + values[16] + values[17] + "'";
			} else if(format == Position.GEO_DMS){
				str = values[0] + values[1] + " " + values[3] + "' " + values[6] + "\" " +
					  values[9] + values[10] + " " + values[12] + "' " + values[15] + "\"";
			} else if(format == Position.GEO_MGRS){
				str = values[0] + values[1] + values[2] + values[3] + values[4] + values[6] + values[6] + values[7] + values[8] + values[9];
			}
			pushNameView(str, format, true);
			pushInfoView(str, null, false);
		}
		
		function onCancel(){
			Ui.popView(transition);
		}
	}
	
	function pushNameView(location, format, back){
		if(Ui has :TextPicker){
			Ui.pushView(new TextNamePicker(), new TextNamePickerDelegate(location, format, back), transition);
		} else {
			Ui.pushView(new NamePicker(), new NamePickerDelegate(location, format, back), transition);
		}
	}
}