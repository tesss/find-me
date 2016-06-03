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
				title = "DD MM.MMMM'";
				pattern = [
					new DirectionFactory(true),
					new DegreeFactory(true),
					getText(" "),
					new MinuteFactory(true),
					getText("."),
					new NumberFactory(),
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
					new NumberFactory(),
					getText("'")
				];
			} else if(_format == Position.GEO_DMS){
				title = "DD MM' SS.SS\"";
				pattern = [
					new DirectionFactory(true),
					new DegreeFactory(true),
					getText(" "),
					new MinuteFactory(true),
					getText("'"),
					getText(" "),
					new MinuteFactory(false),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					getText("\""),
					getText(" "),
					
					new DirectionFactory(false),
					new DegreeFactory(false),
					getText(" "),
					new MinuteFactory(true),
					getText("'"),
					getText(" "),
					new MinuteFactory(false),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					getText("\"")
				];
			}
			
			setOptions({
				:title => getText(title, {:isTitle => true}), 
				:pattern => pattern
			});
		}
		
		function onUpdate(dc) {
	        clearPicker(dc);
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
				str = values[0] + " " + values[1].format("%02d") + "." + values[3] + values[4] + values[5] + values[6] + values[7] + values[8] + " " +
					  values[10] + " " + values[11].format("%03d") + "." + values[13] + values[14] + values[15] + values[16] + values[17] + values[18] + " ";
			} else if(format == Position.GEO_DM){
				str = values[0] + " " + values[1].format("%02d") + " " + values[3].format("%02d") + "." + values[5] + values[6] + values[7] + values[8]  + "'" +
					  values[11] + " " + values[12].format("%03d") + " " + values[14].format("%02d") + "." + values[16] + values[17] + values[18] + values[19] + "'";
			} else if(format == Position.GEO_DMS){
				str = values[0] + " " + values[1].format("%02d") + " " + values[3].format("%02d") + "'" + values[6].format("%02d") + "." + values[8] + values[9] + "\"" +
					  values[12] + " " + values[13].format("%03d") + " " + values[15].format("%02d") + "'" + values[18].format("%02d") + "." + values[20] + values[21] + "\"";
			}
			Ui.popView(transition);
			pushNameView(str, format, defLocationName());
			keepMainView = true;
			pushInfoView(str, false);
		}
		
		function onCancel(){
			Ui.popView(transition);
		}
	}
}