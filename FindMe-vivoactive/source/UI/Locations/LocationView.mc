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
			if(anim){
				return;
			}
			Ui.requestUpdate();
			if(bearing != null && (directionDrawable.angle * 1000).toNumber() != (bearing * 1000).toNumber()){
				anim = true;	
				Ui.animate(directionDrawable, :angle, Ui.ANIM_TYPE_LINEAR, directionDrawable.angle, bearing, 2, method(:animCallback));
			}
		}
		
		function onLayout(){
			directionDrawable = new DirectionDrawable(drawModel.direction, drawModel.directionCenter, 0);
			onTimer(true);
			activityIcon = Ui.loadResource(Rez.Drawables.GpsActivity);
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
				dc.drawText(drawModel.bearing[0], drawModel.bearing[1], Graphics.FONT_SMALL, getLocationStr(location), Graphics.TEXT_JUSTIFY_CENTER);
				
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
					bearing = Data.bearing(
						dataStorage.currentLocation[Data.LAT], 
						dataStorage.currentLocation[Data.LON], 
						location[Data.LOC_LAT], 
						location[Data.LOC_LON]
					) - dataStorage.currentLocation[Data.HEADING];
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
			if(drawModel == null){
				drawModel = new LocationDrawModel();
				drawModel.width = 205;
				drawModel.name = [102, 0];
				drawModel.type = [102, 24];
				drawModel.line1 = [20, 104, 52, 74];
				drawModel.line2 = [152, 74, 185, 104];
				drawModel.line1Dis = [20, 104, 52, 134];
				drawModel.line2Dis = [152, 134, 185, 104];
				drawModel.arrow1 = [[1, 74], [6, 66.500000], [6, 81.500000]];
				drawModel.arrow2 = [[204, 74], [199, 66.500000], [199, 81.500000]];
				drawModel.radius = 35.000000;
				drawModel.distance = [102, 120];
				drawModel.bearing = [102, 64];
				drawModel.direction = [[102, 44], [129.000000, 104], [102, 89.000000], [75.000000, 104]];
				drawModel.directionCenter = [102.000000, 84];
				drawModel.gpsIcon = [5, 26];
				drawModel.activityIcon = [183, 26];
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
			dataStorage.timerCallback = method(:onTimer);
		}
		
		function onHide(){
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
			var locations = model.get();
			locations.fullRefresh = true;
			Ui.pushView(new LocationMenu(locations), new LocationMenuDelegate(model), transition);
		}
	}
}