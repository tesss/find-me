using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Toybox.Position;
using Data;
using _;

module UI{
	function setColor(dc, fcolor, bcolor){
		if(fcolor == null){
			fcolor = COLOR_PRIMARY;
		}
		if(bcolor == null){
			bcolor = COLOR_BACKGROUND;
		}
		dc.setColor(fcolor, bcolor);
	}
	
	function rotate(point, center, angle){
		return [
			(point[0] - center[0]) * Math.cos(angle) - (point[1] - center[1]) * Math.sin(angle) + center[0],
			(point[1] - center[1]) * Math.cos(angle) + (point[0] - center[0]) * Math.sin(angle) + center[1]
		];
	}
	
	function getLocationStr(location){
		// format from settings
		return new Position.Location({
			:latitude => location[Data.LOC_LAT], 
			:longitude => location[Data.LOC_LON], 
			:format => :radians}).toGeoString(dataStorage.getFormat());
	}
	
	function getDistanceStr(distance){
		var isMetric = dataStorage.deviceSettings.distanceUnits == System.UNIT_METRIC;
		if(distance < 0.01){
			distance = 0;
		}
		if(distance < 1){
			var meters = distance * 1000;
			if(isMetric){
				return meters.toNumber() + " m";
			}
			return (meters * 3.2808).toNumber() + " ft";
		} else {
			if(isMetric){
				return distance.format("%.2f") + " km";
			}
			return (distance * 0.621371).format("%.2f") + " mi";
		}
	}

	class LocationView extends Ui.View{
		hidden var model;
		hidden var dots;
	
		function initialize(_model){
			model = _model;
			dots = "";
			Sensor.enableSensorEvents(method(:onSensor));
		}
		
		function onSensor(info){
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
				
				if(dots.length() < 3){
					dots = dots + ".";
				} else {
					dots = "";
				}
				setColor(dc, COLOR_HIGHLIGHT);
				dc.drawText(drawModel.distance[0], drawModel.distance[1], Graphics.FONT_XTINY, "GPS" + dots, Graphics.TEXT_JUSTIFY_CENTER);
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
				
				setColor(dc, COLOR_SECONDARY);
				var p1 = rotate(drawModel.direction[0], drawModel.directionCenter, bearing);
				var p2 = rotate(drawModel.direction[1], drawModel.directionCenter, bearing);
				var p3 = rotate(drawModel.direction[2], drawModel.directionCenter, bearing);
				var p4 = rotate(drawModel.direction[3], drawModel.directionCenter, bearing);
				dc.fillPolygon([p1, p2, p3, p4]);	
				dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
				dc.drawLine(p2[0], p2[1], p3[0], p3[1]);
				dc.drawLine(p3[0], p3[1], p4[0], p4[1]);
				dc.drawLine(p4[0], p4[1], p1[0], p1[1]);
				
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
		
		hidden function draw(location, drawModel, dc){
			setColor(dc, COLOR_PRIMARY);
			dc.clear();
		
			dc.drawText(drawModel.name[0], drawModel.name[1], Graphics.FONT_MEDIUM, location[Data.LOC_NAME], Graphics.TEXT_JUSTIFY_CENTER);
			
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
		}
		
		function getDrawModel(dc){
			if(drawModel == null){
				var w = dc.getWidth();
				var h = dc.getHeight();
				var wc = w / 2;
				var hc = h / 2;
				var hc3 = hc / 3;
				var padding = 20;
				var p;
				var c;
				var ar = 5;
				var a1 = 1.5;
				var a2 = 1;
				var r = 30;
				drawModel = new LocationDrawModel();
				drawModel.line1 = [padding, hc + r, wc - r - padding, hc];
				drawModel.line2 = [wc + r + padding, hc, w - padding, hc + r];
				drawModel.line1Dis = [padding, hc + r, wc - r - padding, hc + 2*r];
				drawModel.line2Dis = [wc + r + padding, hc + 2*r, w - padding, hc + r];
				drawModel.arrow1 = [[wc, a2], [wc + ar * a1, ar + a2], [wc - ar * a1, ar + a2]];
				drawModel.arrow2 = [[wc, h - a2], [wc + ar * a1, h - ar - a2], [wc - ar * a1, h - ar - a2]];
				if(screenType == :round){
					var c = [wc, hc + r * 0.6];
					drawModel.name = [wc, hc3];
					drawModel.type = [wc, hc3 * 2];
					drawModel.distance = [wc, hc3 * 5 - 5];
					drawModel.bearing = [wc, hc3 * 3];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
				} else if (screenType == :square){
					if(dataStorage.deviceSettings.inputButtons & System.BUTTON_INPUT_UP == 0){
						drawModel.arrow1 = [[a2, hc], [ar + a2, hc - ar * a1], [ar + a2, hc + ar * a1]];
						drawModel.arrow2 = [[w - a2, hc], [w - ar - a2, hc - ar * a1], [w - ar - a2, hc + ar * a1]];
						p = 0;
						c = [wc, hc];
					} else {
						p = ar + a2;
						c = [wc, hc + 3];
					}
					drawModel.name = [wc, p];
					drawModel.type = [wc, hc3 + p];
					drawModel.distance = [wc, h - dc.getFontHeight(Graphics.FONT_SMALL) - p];
					drawModel.bearing = [wc, hc - dc.getFontHeight(Graphics.FONT_TINY)/2];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
				} else if (screenType == :tall){
					c = [wc, hc];
					p = 15;
					padding = 5;
					drawModel.name = [wc, p];
					drawModel.type = [wc, hc3 + p];
					drawModel.line1 = [padding, hc + r, wc - r - p, hc];
					drawModel.line2 = [wc + r + p, hc, w - padding, hc + r];
					drawModel.line1Dis = [padding, hc + r, wc - r - p, hc + 2 * r];
					drawModel.line2Dis = [wc + r + p, hc + 2*r, w - padding, hc + r];
					drawModel.distance = [wc, h - dc.getFontHeight(Graphics.FONT_SMALL) - p];
					drawModel.bearing = [wc, hc - dc.getFontHeight(Graphics.FONT_TINY)/2];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
				} else if (type == :semiround){
					c = [wc, hc + 5];
					p = 15;
					drawModel.name = [wc, hc3 - p];
					drawModel.type = [wc, hc3 * 2 - p];
					drawModel.distance = [wc, hc3 * 5 - 5];
					drawModel.bearing = [wc, hc3 * 3];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
				}
			}
			return drawModel;
		}
		
		hidden function getDirectionArrow(c, r){
			var d1 = 0.9;
			var d2 = 0.5;
			var p1 = [c[0], c[1] - r];
			var p2 = [c[0] + r * d1, c[1] + r];
			var p3 = [c[0], c[1] + r * d2];
			var p4 = [c[0] - r * d1, c[1] + r];
			c[0] = (p1[0] + p2[0] + p4[0]) / 3;
			c[1] = (p1[1] + p2[1] + p4[1]) / 3;
			return [p1, p2, p3, p4];
		}
	
		function onUpdate(dc){
			var location = model.get();
			if(location != null){
				draw(location, getDrawModel(dc), dc);
			}
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
		var triangle;
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
		
		function onBack(){
			Ui.popView(transition);
			return true;
		}
		
		function onNextPage(){
			model.get().next();
			Ui.requestUpdate();
		}
		
		function onPreviousPage(){
			model.get().prev();
			Ui.requestUpdate();
		}
		
		function onSelect(){
			Ui.pushView(new LocationMenu(model.get()), new LocationMenuDelegate(model), transition);
		}
	}
}