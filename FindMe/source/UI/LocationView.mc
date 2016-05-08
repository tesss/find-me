using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Data;
using _;

module UI{
	const COLOR_BACKGROUND = 0x000000;
	const COLOR_PRIMARY = 0xFFFFFF;
	const COLOR_SECONDARY = 0xAAAAAA;
	const COLOR_LOWLIGHT = 0x555555;
	const COLOR_HIGHLIGHT = 0xFFAA00;
	const DSIZE = 30;
	
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

	class LocationView extends Ui.View{
		hidden var model;
		hidden var dataStorage;
		
		hidden var w;
		hidden var h;
		hidden var wc;
		hidden var hc;
		hidden var hc3;
		
		hidden var clearingCircle;
		
		hidden var heading;
	
		function initialize(_model, _dataStorage){
			model = _model;
			dataStorage = _dataStorage;
			Sensor.enableSensorEvents(method(:onSensor));
		}
		
		function onSensor(info){
			heading = info.heading;
			Ui.requestUpdate();
		}
		
		hidden function getDistanceStr(distance){
			if(distance == null || heading == null){
				return "...";
			}
			var isMetric = dataStorage.deviceSettings.distanceUnits == System.UNIT_METRIC;
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
		
		hidden function clear(dc){
			setColor(dc, COLOR_BACKGROUND);
			if(clearingCircle != null){
				dc.fillCircle(clearingCircle[0], clearingCircle[1], clearingCircle[2]);
			}
		}
		
		hidden function drawDynamic(location, dc){
			clear(dc);
			dc.fillRectangle(0, hc3 * 5, w, 30);
			
			var distance = null;
			var bearing = null;			
			if(dataStorage.currentLocation != null){
				distance = Data.distance(location[Data.LOC_LAT], location[Data.LOC_LON], dataStorage.currentLocation[Data.LAT], dataStorage.currentLocation[Data.LON]);
				bearing = Data.bearing(location[Data.LOC_LAT], location[Data.LOC_LON], dataStorage.currentLocation[Data.LAT], dataStorage.currentLocation[Data.LON]);
			}
			if(heading == null){
				heading = Sensor.getInfo().heading;
			}
			
			var distanceStr = getDistanceStr(distance);
			setColor(dc, COLOR_HIGHLIGHT);
			dc.drawText(wc, hc3 * 5 - 5, Graphics.FONT_SMALL, distanceStr, Graphics.TEXT_JUSTIFY_CENTER);
			
			if(bearing == null || heading == null){
				setColor(dc, COLOR_SECONDARY);
				dc.drawText(wc, hc3 * 3, Graphics.FONT_MEDIUM, "...", Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				bearing = Math.toRadians(bearing) - heading;
				
				var t1 = 0.9;
				var t2 = 0.5;
				var t3 = 0.65;
				var r = DSIZE;
				var c = [wc, hc + r * t3];
				
				var p1 = [c[0], c[1] - r];
				var p2 = [c[0] + r * t1, c[1] + r];
				var p3 = [c[0] - r * t1, c[1] + r];
				var p4 = [c[0], c[1] + r * t2];
				c = [(p1[0] + p2[0] + p3[0]) / 3, (p1[1] + p2[1] + p3[1]) / 3];
				
				if(clearingCircle == null){
					clearingCircle = [c[0], c[1], c[1] - p1[1] + 1];
				}
				clear(dc);
				setColor(dc, COLOR_SECONDARY);
				
				p1 = rotate(p1, c, bearing);
				p2 = rotate(p2, c, bearing);
				p3 = rotate(p3, c, bearing);
				p4 = rotate(p4, c, bearing);
				
				dc.fillPolygon([p1, p2, p4, p3]);
				
				setColor(dc, COLOR_SECONDARY);
				dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
				dc.drawLine(p2[0], p2[1], p4[0], p4[1]);
				dc.drawLine(p4[0], p4[1], p3[0], p3[1]);
				dc.drawLine(p3[0], p3[1], p1[0], p1[1]);
			}
		}
		
		hidden function rotate(point, center, angle){
			return [
				(point[0] - center[0]) * Math.cos(angle) - (point[1] - center[1]) * Math.sin(angle) + center[0],
				(point[1] - center[1]) * Math.cos(angle) + (point[0] - center[0]) * Math.sin(angle) + center[1]
			];
		}
		
		hidden function onUpdateRound(location, dc){
			if(model.fullRefresh){
				setColor(dc, COLOR_PRIMARY);
				dc.clear();
				
				w = dc.getWidth();
				h = dc.getHeight();
				wc = w / 2;
				hc = h / 2;
				hc3 = hc / 3;
				
				dc.drawText(wc, hc3, Graphics.FONT_MEDIUM, location[Data.LOC_NAME], Graphics.TEXT_JUSTIFY_CENTER);
				
				setColor(dc, COLOR_LOWLIGHT);
				var padding = 20;
				dc.drawLine(padding, hc + DSIZE, wc - DSIZE - padding, hc);
				dc.drawLine(wc + DSIZE + padding, hc, w - padding, hc + DSIZE);
				
				setColor(dc, COLOR_SECONDARY);
				dc.drawText(wc, hc3 * 2, Graphics.FONT_TINY, Data.DataStorage.TYPES[location[Data.LOC_TYPE]], Graphics.TEXT_JUSTIFY_CENTER);
				model.fullRefresh = false;
				
				if(model.showArrows()){
					setColor(dc, COLOR_LOWLIGHT);
					var r = 5;
					var t1 = 1.5;
					var t2 = 1;
					var p1 = [wc, t2];
					var p2 = [wc + r * t1, r + t2];
					var p3 = [wc - r * t1, r + t2];
					dc.fillPolygon([p1, p2, p3]);
					p1 = [wc, h - t2];
					p2 = [wc + r * t1, h - r - t2];
					p3 = [wc - r * t1, h - r - t2];
					dc.fillPolygon([p1, p2, p3]);
				}
			}
			drawDynamic(location, dc);
		}
	
		function onUpdate(dc){
			var location = model.get();
			if(dataStorage.deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND){
				onUpdateRound(location, dc);
			}
		}
	}
	
	class LocationDelegate extends Ui.BehaviorDelegate{
		hidden var model;
		
		function initialize(_model){
			model = _model;
		}
		
		function onNextPage(){
			model.next();
			Ui.requestUpdate();
		}
		
		function onPreviousPage(){
			model.prev();
			Ui.requestUpdate();
		}
	}
}