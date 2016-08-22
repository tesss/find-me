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
		hidden var bearing;
		hidden var heading;
		hidden var gpsIcon;
		hidden var activityIcon;
		
		var directionDrawable;
		
		const TYPES_BCOLORS = [
			Graphics.COLOR_WHITE,
			Graphics.COLOR_LT_GRAY,
			Graphics.COLOR_RED,
			Graphics.COLOR_BLUE,
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
			getDrawModel();
		}
		
		function dispose(){
			dataStorage.timerCallback = null;
			Sensor.enableSensorEvents(null);
			gpsIcon = null;
			activityIcon = null;
			directionDrawable = null;
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
				model.fullRefresh = true;
				Ui.requestUpdate();
			}
		}
		
		function onSensor(info){
			Ui.requestUpdate();
			if(info == null || (info.speed != null && info.speed > Data.SPEED_LIMIT && dataStorage.getInterval() > 0)){
				heading = null;
			} else {
				heading = info.heading;
			}
			if(bearing != null){
				var t1 = directionDrawable.angle;
				var t2 = bearing;
				var sign;
				if((t1 - t2).abs() > Math.PI){
					if(t1.abs() > Math.PI){
						sign = t1 < 0 ? 1 : -1;
						t1 = t1 + sign * Math.PI * 2;
					} else {
						sign = t2 < 0 ? 1 : -1;
						t2 = t2 + sign * Math.PI * 2;
					}
				}
				var d = t1 - t2;
				if(d.abs() > 0.017){
					Ui.animate(directionDrawable, :angle, Ui.ANIM_TYPE_LINEAR, t1, t2, 2);
				}
			}
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
				
				var str = "MANUAL GPS";
				if(dataStorage.gpsFinding){
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
				
				setColor(dc, COLOR_HIGHLIGHT);
				dc.drawText(drawModel.distance[0], drawModel.distance[1], Graphics.FONT_MEDIUM, getDistanceStr(distance), Graphics.TEXT_JUSTIFY_CENTER);
				
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
					if(bearing != null && !model.fullRefresh){
						Alert.alert(Alert.ZERO_DISTANCE);
					}
					bearing = null;
					setColor(dc, COLOR_LOWLIGHT);
					dc.fillCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], drawModel.radius);
					setColor(dc, COLOR_SECONDARY);
					dc.drawCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], drawModel.radius);
					setColor(dc, COLOR_HIGHLIGHT);
					dc.fillCircle(drawModel.directionCenter[0], drawModel.directionCenter[1], 10);
				}
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
				dataStorage.TYPES[location[Data.LOC_TYPE]].toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
			
			if(model.showArrows()){
				setColor(dc, COLOR_LOWLIGHT);
				dc.fillPolygon(drawModel.arrow1);
				dc.fillPolygon(drawModel.arrow2);
			}
			drawDynamic(location, dc);
			dc.setPenWidth(1);
		}
		
		function getDrawModel(){
			if(drawModel == null){
				drawModel = new LocationDrawModel();
				drawModel.width = 148;
				drawModel.name = [74, 7];
				drawModel.type = [74, 38];
				drawModel.line1 = [5, 132, 29, 72];
				drawModel.line2 = [119, 72, 143, 132];
				drawModel.line1Dis = [5, 132, 29, 162];
				drawModel.line2Dis = [119, 162, 143, 132];
				drawModel.arrow1 = [[74, 1], [81.500000, 6], [66.500000, 6]];
				drawModel.arrow2 = [[74, 204], [81.500000, 199], [66.500000, 199]];
				drawModel.radius = 35.000000;
				drawModel.distance = [74, 168];
				drawModel.bearing = [74, 93];
				drawModel.direction = [[74, 72], [101.000000, 132], [74, 117.000000], [47.000000, 132]];
				drawModel.directionCenter = [74.000000, 112];
				drawModel.gpsIcon = [10, 40];
				drawModel.activityIcon = [122, 40];
			}
			return drawModel;
		}
	
		function onUpdate(dc){
			var location = model.get();
			if(location != null){
				draw(location, dc);
			}
			model.fullRefresh = false;
		}
		
		function onShow(){
			directionDrawable = new DirectionDrawable(drawModel.direction, drawModel.directionCenter, bearing != null ? bearing : 0);
			activityIcon = Ui.loadResource(Rez.Drawables.GpsActivity);
			onTimer(true);
			Sensor.enableSensorEvents(method(:onSensor));
			dataStorage.timerCallback = method(:onTimer);
		}
		
		function onHide(){
			dispose();
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
			Ui.popView(transition);
			return true;
		}
		
		function onSelect(){
			if(dataStorage.getInterval() == -1 && !dataStorage.gpsFinding){
				dataStorage.onTimer(true);
				Alert.alert(Alert.GPS_MANUAL);
			}
		}
		
		function onMenu(){
			var locations = model.get();
			locations.fullRefresh = true;
			Ui.pushView(new LocationMenu(locations), new LocationMenuDelegate(model), transition);
		}
	}
}