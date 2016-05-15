using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Position;
using Toybox.Lang;
using Data;

module UI{
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
}