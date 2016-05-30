using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Toybox.Position;
using Data;
using Alert;
using _;

module UI{
	class LocationView extends Ui.View{
		hidden var model;
		hidden var dots;
		hidden var interval;
		hidden var anim;
		hidden var bearing;
		hidden var heading;
		hidden var gpsIcon;
		hidden var activityIcon;
		
		var directionDrawable;
		
		const TYPES_BCOLORS = [
			Graphics.COLOR_WHITE,
			Graphics.COLOR_LT_GRAY,
			Graphics.COLOR_DK_RED,
			Graphics.COLOR_DK_BLUE,
			Graphics.COLOR_BLUE,
			Graphics.COLOR_DK_GREEN,
			Graphics.COLOR_GREEN,
			Graphics.COLOR_WHITE,
			Graphics.COLOR_ORANGE,
			Graphics.COLOR_LT_GRAY,
			Graphics.COLOR_PURPLE,
			Graphics.COLOR_YELLOW,
			Graphics.COLOR_PINK,
			Graphics.COLOR_RED,
			Graphics.COLOR_DK_GREEN,
			Graphics.COLOR_WHITE
		];
	
		function initialize(_model){
			model = _model;
			dots = "";
			interval = dataStorage.getInterval();
			anim = false;
			getDrawModel();
		}
		
		function onTimer(accuracyChanged){
			if(accuracyChanged){
				var accuracy = dataStorage.currentLocation == null ? null : dataStorage.currentLocation[Data.ACCURACY];
				if(accuracy == null || accuracy == Position.QUALITY_NOT_AVAILABLE){
					gpsIcon = null;
				} else if(accuracy == Position.QUALITY_LAST_KNOWN){
					gpsIcon = Ui.loadResource(Rez.Drawables.GpsLast);
				} else if(accuracy == Position.QUALITY_POOR){
					gpsIcon = Ui.loadResource(Rez.Drawables.GpsPoor);
				} else if(accuracy == Position.QUALITY_USABLE){
					gpsIcon = Ui.loadResource(Rez.Drawables.GpsUsable);
				} else if(accuracy == Position.QUALITY_GOOD){
					gpsIcon = Ui.loadResource(Rez.Drawables.GpsGood);
				}
			}
		}
		
		function onLayout(){
			directionDrawable = new DirectionDrawable(drawModel.direction, drawModel.directionCenter, 0);
			onTimer(true);
			activityIcon = Ui.loadResource(Rez.Drawables.GpsActivity);
		}
		
		function onSensor(info){
			if(anim){
				return;
			}
			Ui.requestUpdate();
			if(info != null && info.heading != null && info.heading > 0){
				heading = info.heading;
			} else {
				heading = null;
			}
			if(bearing != null && (directionDrawable.angle * 1000).toNumber() != (bearing * 1000).toNumber()){
				anim = true;	
				Ui.animate(directionDrawable, :angle, Ui.ANIM_TYPE_LINEAR, directionDrawable.angle, bearing, 1, method(:animCallback));
			}
		}
		
		function animCallback(){
			anim = false;
			Ui.requestUpdate();
		}
		
		hidden function drawDynamic(location, dc){
			if(dataStorage.currentLocation == null || dataStorage.currentLocation[Data.ACCURACY] == Position.QUALITY_NOT_AVAILABLE){
				bearing = null;
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
				dots = "";

				setColor(dc, COLOR_LOWLIGHT);
				dc.drawLine(drawModel.line1[0], drawModel.line1[1], drawModel.line1[2], drawModel.line1[3]);
				dc.drawLine(drawModel.line2[0], drawModel.line2[1], drawModel.line2[2], drawModel.line2[3]);
				
				if(distance > Data.ZERO_LIMIT){
					var angle = heading == null ? dataStorage.currentLocation[Data.HEADING] : heading;
					bearing = Data.bearing(
						dataStorage.currentLocation[Data.LAT], 
						dataStorage.currentLocation[Data.LON], 
						location[Data.LOC_LAT], 
						location[Data.LOC_LON]
					) - angle;
					directionDrawable.draw(dc);
				} else {
					if(bearing != null){
						Alert.alert(Alert.ZERO_DISTANCE);
					}
					bearing = null;
					setColor(dc, COLOR_SECONDARY);
					dc.drawCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], drawModel.radius);
					setColor(dc, COLOR_HIGHLIGHT);
					dc.fillCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], 10);
				}
				
				setColor(dc, COLOR_HIGHLIGHT);
				dc.drawText(drawModel.distance[0], drawModel.distance[1], Graphics.FONT_MEDIUM, getDistanceStr(distance), Graphics.TEXT_JUSTIFY_CENTER);
			}
		}
		
		hidden function draw(location, dc){
			setColor(dc, COLOR_PRIMARY);
			dc.clear();
			if(gpsIcon != null){
				dc.drawBitmap(drawModel.gpsIcon[0], drawModel.gpsIcon[1], gpsIcon);
			}
			if(dataStorage.session != null){
				dc.drawBitmap(drawModel.activityIcon[0], drawModel.activityIcon[1], activityIcon);
			}
		
			dc.setPenWidth(3);
			
			var color = TYPES_BCOLORS[location[Data.LOC_TYPE]];
			setColor(dc, color);
			var font = Graphics.FONT_SMALL;
			dc.fillRectangle(0, drawModel.name[1], drawModel.width, dc.getFontHeight(font) + 1);
			setColor(dc, COLOR_BACKGROUND, color);
			dc.drawText(drawModel.name[0], drawModel.name[1], font, location[Data.LOC_NAME], Graphics.TEXT_JUSTIFY_CENTER);
			
			setColor(dc, COLOR_SECONDARY);
			dc.drawText(drawModel.type[0], drawModel.type[1], Graphics.FONT_XTINY, 
				Data.DataStorage.TYPES[location[Data.LOC_TYPE]], Graphics.TEXT_JUSTIFY_CENTER);
			
			if(model.showArrows()){
				setColor(dc, COLOR_LOWLIGHT);
				dc.fillPolygon(drawModel.arrow1);
				dc.fillPolygon(drawModel.arrow2);
			}
			drawDynamic(location, dc);
			dc.setPenWidth(1);
		}
		
		function getDrawModel(){
			var screenType = :square;
			if(drawModel == null){
				var w = 205;
				var h = 148;
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
				var dr = 5;
				drawModel = new LocationDrawModel();
				drawModel.width = w;
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
					drawModel.radius = getDistance(drawModel.direction[0], drawModel.directionCenter) - dr;
				} else if (screenType == :square){
					if(System.getDeviceSettings().inputButtons & System.BUTTON_INPUT_UP == 0){
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
					drawModel.distance = [wc, h - Graphics.getFontHeight(Graphics.FONT_MEDIUM) - p];
					drawModel.bearing = [wc, hc - Graphics.getFontHeight(Graphics.FONT_TINY)/2];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
					drawModel.radius = getDistance(drawModel.direction[0], drawModel.directionCenter) - dr;
					var icondx = wc - 5;
					var icondy = hc3 + p + 2;
					drawModel.gpsIcon = [wc-icondx, icondy];
					drawModel.activityIcon = [wc+icondx-16, icondy];
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
					drawModel.distance = [wc, h - Graphics.getFontHeight(Graphics.FONT_SMALL) - p];
					drawModel.bearing = [wc, hc - Graphics.getFontHeight(Graphics.FONT_TINY)/2];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
					drawModel.radius = getDistance(drawModel.direction[0], drawModel.directionCenter) - dr;
				} else if (type == :semiround){
					c = [wc, hc + 5];
					p = 15;
					drawModel.name = [wc, hc3 - p];
					drawModel.type = [wc, hc3 * 2 - p];
					drawModel.distance = [wc, hc3 * 5 - 5];
					drawModel.bearing = [wc, hc3 * 3];
					drawModel.direction = getDirectionArrow(c, r);
					drawModel.directionCenter = c;
					drawModel.radius = getDistance(drawModel.direction[0], drawModel.directionCenter) - dr;
				}
			}
			return drawModel;
		}
		
		function getDistance(p1, p2){
			var d1 = p2[0] - p1[0];
			var d2 = p2[1] - p1[1];
			return Math.sqrt(d1*d1 + d2*d2);
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
			if(anim && !model.fullRefresh){
				dc.setColor(COLOR_BACKGROUND, COLOR_PRIMARY);
				dc.fillCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], drawModel.radius + 7);
				directionDrawable.draw(dc);
			} else {
				var location = model.get();
				if(location != null){
					draw(location, dc);
				}
				model.fullRefresh = false;
			}
		}
		
		function onShow(){
			Sensor.enableSensorEvents(method(:onSensor));
			dataStorage.timerCallback = method(:onTimer);
		}
		
		function onHide(){
			//gpsIcon = null;
			//activityIcon = null;
			Sensor.enableSensorEvents(null);
			dataStorage.timerCallback = null;
		}
	}
	
	class LocationDrawModel {
		var width;
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
		var gpsIcon;
		var activityIcon;
		
		function toString(){
			return "drawModel = new LocationDrawModel();\n"+
				"drawModel.width = " + drawModel.width + ";\n" +
				"drawModel.name = " + drawModel.name + ";\n" +
				"drawModel.type = " + drawModel.type + ";\n" +
				"drawModel.line1 = " + drawModel.line1 + ";\n" +
				"drawModel.line2 = " + drawModel.line2+ ";\n" +
				"drawModel.line1Dis = " + drawModel.line1Dis + ";\n" +
				"drawModel.line2Dis = " + drawModel.line2Dis + ";\n" +
				"drawModel.arrow1 = " + drawModel.arrow1 + ";\n" +
				"drawModel.arrow2 = " + drawModel.arrow2 + ";\n" +
				"drawModel.radius = " + drawModel.radius + ";\n" +
				"drawModel.distance = " + drawModel.distance + ";\n" +
				"drawModel.bearing = " + drawModel.bearing + ";\n" +
				"drawModel.direction = " + drawModel.direction + ";\n" +
				"drawModel.directionCenter = " + drawModel.directionCenter + ";\n" +
				"drawModel.gpsIcon = " + drawModel.gpsIcon + ";\n" +
				"drawModel.activityIcon = " + drawModel.activityIcon + ";";
		}
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
			var locations = model.get();
			locations.fullRefresh = true;
			Ui.pushView(new LocationMenu(locations), new LocationMenuDelegate(model), transition);
		}
	}
}