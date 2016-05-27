using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Toybox.Position;
using Data;
using _;

module UI{
	class LocationView extends Ui.View{
		hidden var model;
		hidden var dots;
		hidden var interval;
	
		function initialize(_model){
			model = _model;
			dots = "";
			interval = dataStorage.getInterval();
			Sensor.enableSensorEvents(method(:onSensor));
		}
		
		function onSensor(info){
			// doesn't update from compass
			Ui.requestUpdate();
		}
		
		hidden function drawDynamic(location, drawModel, dc){
			if(dataStorage.currentLocation == null || dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_NOT_AVAILABLE){
				// Forerunner 920xt - location doesn't show
				setColor(dc, COLOR_SECONDARY);
				dc.drawText(drawModel.bearing[0], drawModel.bearing[1], Graphics.FONT_TINY, getLocationStr(location), Graphics.TEXT_JUSTIFY_CENTER);
				
				setColor(dc, COLOR_LOWLIGHT);
				dc.drawLine(drawModel.line1Dis[0], drawModel.line1Dis[1], drawModel.line1Dis[2], drawModel.line1Dis[3]);
				dc.drawLine(drawModel.line2Dis[0], drawModel.line2Dis[1], drawModel.line2Dis[2], drawModel.line2Dis[3]);
				
				var str = "NO GPS";
				if(interval >= 0){
					if(dots.length() < 3){
						dots = dots + ".";
					} else {
						dots = "";
					}
					str = "GPS" + dots;
				}
				setColor(dc, COLOR_HIGHLIGHT);
				dc.drawText(drawModel.distance[0], drawModel.distance[1], Graphics.FONT_XTINY, str, Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				var distance = Data.distance(
					location[Data.LOC_LAT], 
					location[Data.LOC_LON], 
					dataStorage.currentLocation[Data.LAT], 
					dataStorage.currentLocation[Data.LON]);
				var bearing = Data.bearing(
					dataStorage.currentLocation[Data.LAT], 
					dataStorage.currentLocation[Data.LON], 
					location[Data.LOC_LAT], 
					location[Data.LOC_LON]) - dataStorage.currentLocation[Data.HEADING];
				dots = "";

				setColor(dc, COLOR_LOWLIGHT);
				dc.drawLine(drawModel.line1[0], drawModel.line1[1], drawModel.line1[2], drawModel.line1[3]);
				dc.drawLine(drawModel.line2[0], drawModel.line2[1], drawModel.line2[2], drawModel.line2[3]);
				
				if(distance > Data.ZERO_LIMIT){
					setColor(dc, COLOR_SECONDARY);
					var p1 = rotate(drawModel.direction[0], drawModel.directionCenter, bearing);
					var p2 = rotate(drawModel.direction[1], drawModel.directionCenter, bearing);
					var p3 = rotate(drawModel.direction[2], drawModel.directionCenter, bearing);
					var p4 = rotate(drawModel.direction[3], drawModel.directionCenter, bearing);
					dc.fillPolygon([p1, p2, p3, p4]);
									
					setColor(dc, COLOR_LOWLIGHT);
					dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
					dc.drawLine(p2[0], p2[1], p3[0], p3[1]);
					dc.drawLine(p3[0], p3[1], p4[0], p4[1]);
					dc.drawLine(p4[0], p4[1], p1[0], p1[1]);
				} else {
					setColor(dc, COLOR_SECONDARY);
					dc.drawCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], drawModel.radius);
					setColor(dc, COLOR_HIGHLIGHT);
					dc.fillCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], 10);
				}
				
				setColor(dc, COLOR_HIGHLIGHT);
				dc.drawText(drawModel.distance[0], drawModel.distance[1], Graphics.FONT_SMALL, getDistanceStr(distance), Graphics.TEXT_JUSTIFY_CENTER);
			}
		}
		
		hidden function rotate(point, center, angle){
			return [
				(point[0] - center[0]) * Math.cos(angle) - (point[1] - center[1]) * Math.sin(angle) + center[0],
				(point[1] - center[1]) * Math.cos(angle) + (point[0] - center[0]) * Math.sin(angle) + center[1]
			];
		}
		
		hidden function getNameColor(type){
			if(type <= 2){
				return Graphics.COLOR_BLUE;
			}
			if(type <= 3){
				return Graphics.COLOR_RED;
			}
			if(type <= 7){
				return Graphics.COLOR_GREEN;
			}
			if(type <= 14){
				return Graphics.COLOR_YELLOW;
			}
			return Graphics.COLOR_LT_GRAY;
		}
		
		hidden function draw(location, drawModel, dc){
			setColor(dc, COLOR_PRIMARY);
			dc.clear();
		
			dc.setPenWidth(3);
			
			var color = getNameColor(location[Data.LOC_TYPE]);
			setColor(dc, color);
			var font = Graphics.FONT_SMALL;
			dc.fillRectangle(0, drawModel.name[1], dc.getWidth(), dc.getFontHeight(font) + 1);
			setColor(dc, COLOR_BACKGROUND, color);
			dc.drawText(drawModel.name[0], drawModel.name[1], font, location[Data.LOC_NAME], Graphics.TEXT_JUSTIFY_CENTER);
			
			setColor(dc, COLOR_LOWLIGHT);
			
			setColor(dc, COLOR_SECONDARY);
			dc.drawText(drawModel.type[0], drawModel.type[1], Graphics.FONT_XTINY, 
				Data.DataStorage.TYPES[location[Data.LOC_TYPE]], Graphics.TEXT_JUSTIFY_CENTER);
			model.fullRefresh = false;
			
			if(model.showArrows()){
				setColor(dc, COLOR_LOWLIGHT);
				dc.fillPolygon(drawModel.arrow1);
				dc.fillPolygon(drawModel.arrow2);
			}
			drawDynamic(location, drawModel, dc);
			dc.setPenWidth(1);
		}
		
		function getDrawModel(dc){
			if(drawModel == null){
				drawModel = new LocationDrawModel();
				drawModel.name = [109, 36];
				drawModel.type = [109, 72];
				drawModel.line1 = [20, 139, 59, 109];
				drawModel.line2 = [159, 109, 198, 139];
				drawModel.line1Dis = [20, 139, 59, 169];
				drawModel.line2Dis = [159, 169, 198, 139];
				drawModel.arrow1 = [[109, 1], [116.500000, 6], [101.500000, 6]];
				drawModel.arrow2 = [[109, 217], [116.500000, 212], [101.500000, 212]];
				drawModel.radius = 35;
				drawModel.distance = [109, 175];
				drawModel.bearing = [109, 108];
				drawModel.direction = [[109, 97.000000], [136.000000, 157.000000], [109, 142.000000], [82.000000, 157.000000]];
				drawModel.directionCenter = [109.000000, 137.000000];
			}
			return drawModel;
		}
	
		function onUpdate(dc){
			var location = model.get();
			if(location != null){
				draw(location, getDrawModel(dc), dc);
			}
		}
		
		function getDistance(p1, p2){
			var d1 = p2[0] - p1[0];
			var d2 = p2[1] - p1[1];
			return Math.sqrt(d1*d1 + d2*d2);
		}
		
		function sort(){
			model.sort();
		}
		
		function onShow(){
			if(dataStorage.getSortBy() == Data.SORTBY_DISTANCE){
				dataStorage.timerCallback = method(:sort).weak();
			}
		}
	}
	
	class LocationDrawModel {
		var name;
		var type;
		var line1;
		var line2;
		var line1Dis;
		var line2Dis;
		var arrow1;
		var arrow2;
		var radius;
		var distance;
		var bearing;
		var direction;
		var directionCenter;
	}
	
	class LocationDelegate extends Ui.BehaviorDelegate{
		hidden var model;
		
		function initialize(_model){
			model = _model;
		}
		
		function onNextPage(){
			model.get().next();
			Ui.requestUpdate();
		}
		
		function onPreviousPage(){
			model.get().prev();
			Ui.requestUpdate();
		}
		
		function onBack(){
			if(model.global){
				Ui.popView(transition);
				return true;
			}
			Ui.popView(transition);
			return false;
		}
		
		function onSelect(){
			Ui.pushView(new LocationMenu(model.get()), new LocationMenuDelegate(model), transition);
		}
	}
}