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
				title = "DD.DDDD";
				pattern = [
					new DirectionFactory(true), 
					new NumberFactory(9),
					new NumberFactory(),
					getText("."),
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
					new NumberFactory()
				];
			} else if(_format == Position.GEO_DM){
				title = "DD MM.MM'";
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
					getText("'")
				];
			} else if(_format == Position.GEO_DMS){
				title = "DD MM' SS\"";
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
		
		function replaceIfZero(values){
			var str = "";
			var z = true;
			for(var i = 0; i < values.size(); i++){
				if(z && values[i] == 0 && i != values.size() - 1){
					//str = str + " ";
				} else {
					z = false;
					str = str + values[i];
				}
			}
			return str;
		}
	
		function onAccept(values){
			var str = null;
			if(format == Position.GEO_DEG){
				if(checkDegrees(values[10].toString() + values[11] + values[12].toString())) {
					str = values[0] + replaceIfZero([values[1], values[2]]) + "." + values[4] + values[5] + values[6] + values[7] + "," +
					  	  values[9] + replaceIfZero([values[10], values[11], values[12]]) + "." + values[14] + values[15] + values[16] + values[17];
				}
			} else if(format == Position.GEO_DM){
				if(checkDegrees(values[12].toString() + values[13].toString() + values[14].toString())) {
					str = values[0] + replaceIfZero([values[1], values[2]]) + " " + replaceIfZero([values[4], values[5]]) + "." + values[7] + values[8] + "'" +
					  	  values[11] + replaceIfZero([values[12], values[13], values[14]]) + " " + replaceIfZero([values[16], values[17]]) + "." + values[19] + values[20] + "'";
				}
			} else if(format == Position.GEO_DMS){
				if(checkDegrees(values[13].toString() + values[14].toString() + values[15].toString())) {
					str = values[0] + replaceIfZero([values[1], values[2]]) + " " + replaceIfZero([values[4], values[5]]) + "'" + replaceIfZero([values[8], values[9]]) + "\"" +
					  	  values[12] + replaceIfZero([values[13], values[14], values[15]]) + " " + replaceIfZero([values[17], values[18]]) + "'" + replaceIfZero([values[21], values[22]]) + "\"";
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