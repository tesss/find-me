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
			anim = false;
			getDrawModel();
		}
		
		function onTimer(accuracyChanged){
			if(accuracyChanged){
				var accuracy = dataStorage.currentLocation == null ? null : dataStorage.currentLocation[Data.ACCURACY];
				if(accuracy == null || accuracy == Position.QUALITY_NOT_AVAILABLE){
					gpsIcon = null;
				} else if(accuracy == Position.QUALITY_LAST_KNOWN || dataStorage.getInterval() == -1){
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
			if(info == null || (info.speed != null && info.speed > Data.SPEED_LIMIT && dataStorage.getInterval() > 0)){
				heading = null;
			} else {
				heading = Data.heading(info);
			}
			if(bearing != null && (directionDrawable.angle * 1000).toNumber() != (bearing * 1000).toNumber()){
				anim = true;
				var t1 = directionDrawable.angle;
				var t2 = bearing;
				if((t1 - t2).abs() > Math.PI){
					if(t1 > Math.PI){
						t1 = t1 - Math.PI * 2;
					} else {
						t2 = t2 - Math.PI * 2;
					}
				}
				Ui.animate(directionDrawable, :angle, Ui.ANIM_TYPE_LINEAR, t1, t2, 2, method(:animCallback));
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
				
				var str = "MANUAL GPS";
				if(interval >= 0 || dataStorage.gpsFinding){
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
				dc.drawText(drawModel.distance[0], drawModel.distance[1], Graphics.FONT_NUMBER_MILD, getDistanceStr(distance), Graphics.TEXT_JUSTIFY_CENTER);
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
			if(drawModel == null){
				drawModel = new LocationDrawModel();
				drawModel.width = 218;
				drawModel.name = [109, 36];
				drawModel.type = [109, 72];
				drawModel.line1 = [20, 139, 59, 109];
				drawModel.line2 = [159, 109, 198, 139];
				drawModel.line1Dis = [20, 139, 59, 169];
				drawModel.line2Dis = [159, 169, 198, 139];
				drawModel.arrow1 = [[109, 1], [116.500000, 6], [101.500000, 6]];
				drawModel.arrow2 = [[109, 217], [116.500000, 212], [101.500000, 212]];
				drawModel.radius = 35;
				drawModel.distance = [109, 174];
				drawModel.bearing = [109, 108];
				drawModel.direction = [[109, 97.000000], [136.000000, 157.000000], [109, 142.000000], [82.000000, 157.000000]];
				drawModel.directionCenter = [109.000000, 137.000000];
				drawModel.gpsIcon = [84, 14];
				drawModel.activityIcon = [120, 14];
			}
			return drawModel;
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
			if(dataStorage.getInterval() == -1){
				dataStorage.onTimer();
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