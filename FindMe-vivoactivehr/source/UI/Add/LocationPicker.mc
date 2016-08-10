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
					new NumberFactory(9),
					new NumberFactory(),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					getText(" "),
					
					new DirectionFactory(false),
					new NumberFactory(2),
					new NumberFactory(),
					new NumberFactory(),
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
					new NumberFactory(9),
					new NumberFactory(),
					getText(" "),
					new NumberFactory(6),
					new NumberFactory(),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					new NumberFactory(),
					getText("'"),
					getText(" "),
					
					new DirectionFactory(false),
					new NumberFactory(2),
					new NumberFactory(),
					new NumberFactory(),
					getText(" "),
					new NumberFactory(6),
					new NumberFactory(),
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
					new NumberFactory(9),
					new NumberFactory(),
					getText(" "),
					new NumberFactory(6),
					new NumberFactory(),
					getText("'"),
					getText(" "),
					new NumberFactory(6),
					new NumberFactory(),
					getText("."),
					new NumberFactory(),
					new NumberFactory(),
					getText("\""),
					getText(" "),
					
					new DirectionFactory(false),
					new NumberFactory(2),
					new NumberFactory(),
					new NumberFactory(),
					getText(" "),
					new NumberFactory(6),
					new NumberFactory(),
					getText("'"),
					getText(" "),
					new NumberFactory(6),
					new NumberFactory(),
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
		
		function checkDegrees(str){
			if(str.toNumber() > 179){
				pushInfoView("Degrees error");
				return false;
			}
			return true;
		}
	
		function onAccept(values){
			var str = null;
			if(format == Position.GEO_DEG){
				if(checkDegrees(values[12].toString() + values[13] + values[14].toString())) {
					str = values[0] + " " + values[1] + values[2] + "." + values[4] + values[5] + values[6] + values[7] + values[8] + values[9] + " " +
					  	  values[11] + " " + values[12] + values[13] + values[14] + "." + values[16] + values[17] + values[18] + values[19] + values[20] + values[21] + " ";
				}
			} else if(format == Position.GEO_DM){
				if(checkDegrees(values[14].toString() + values[15].toString() + values[16].toString())) {
					str = values[0] + " " + values[1] + values[2] + " " + values[4] + values[5] + "." + values[7] + values[8] + values[9] + values[10] + "'" +
					  	  values[13] + " " + values[14] + values[15] + values[16] + " " + values[18] + values[19] + "." + values[21] + values[22] + values[23] + values[24] + "'";
				}
			} else if(format == Position.GEO_DMS){
				if(checkDegrees(values[16].toString() + values[17].toString() + values[18].toString())) {
					str = values[0] + " " + values[1] + values[2] + " " + values[4] + values[5] + "'" + values[8] + values[9] + "." + values[11] + values[12] + "\"" +
					  	  values[15] + " " + values[16] + values[17] + values[18] + " " + values[20] + values[21] + "'" + values[24] + values[25] + "." + values[27] + values[28] + "\"";
				}
			}
			if(str != null){
				Ui.popView(transition);
				pushNameView(str, format, defLocationName());
				keepMainView = true;
				pushInfoView(str, false);
			}
		}
		
		function onCancel(){
			Ui.popView(transition);
		}
	}
}