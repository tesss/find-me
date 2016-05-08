using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Data;
using _;

module UI{
	const COLOR_BACKGROUND = 0xFFFFFF;
	const COLOR_PRIMARY = 0x000000;
	const COLOR_SECONDARY = 0xAAAAAA;
	const COLOR_LOWLIGHT = 0xAAAAAA;
	const COLOR_HIGHLIGHT = 0xAA0000;
	const DSIZE = 30;
	
	function setColor(dc, fcolor, bcolor){
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
	
	function getDistanceStr(distance){
		if(distance == null){
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

	class LocationView extends Ui.View{
		hidden var model;
		hidden var dataStorage;
	
		function initialize(_model, _dataStorage){
			model = _model;
			dataStorage = _dataStorage;
		}
	
		function onUpdate(dc){
			var location = model.get();
			if(dataStorage.deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND){
				//onUpdateRound(location, dc);
				var distance = null;
				var bearing = null;
				if(dataStorage.currentLocation != null){
					distance = Data.distance(location[Data.LOC_LAT], location[Data.LOC_LON], dataStorage.currentLocation[Data.LAT], dataStorage.currentLocation[Data.LON]);
					bearing = Data.bearing(location[Data.LOC_LAT], location[Data.LOC_LON], dataStorage.currentLocation[Data.LAT], dataStorage.currentLocation[Data.LON]);
					var info = Sensor.getInfo();
					bearing = Math.toRadians(bearing) - info.heading;
				}
				distance = getDistanceStr(distance);
				var options = {
					:distance => distance,
					:bearing => bearing,
					:height => dc.getHeight(),
					:width => dc.getWidth()
				};
				if(model.animNext == null){
					new LocationRoundDrawable(options).draw(dc);
					dc.draw(new LocationRoundDrawable(options));
				} else {
					options.put(:name, location[Data.LOC_NAME]);
					options.put(:type, Data.DataStorage.TYPES[location[Data.LOC_TYPE]]);
					options.put(:showArrows, model.showArrows());
					if(model.animNext){
						Ui.animate(new LocationRoundDrawable(options).draw(dc), locX, Ui.ANIM_TYPE_EASE_IN, -, stop, period, callback)
						; // animation
						model.animNext = null;
					} else {
						new LocationRoundDrawable(options).draw(dc);
						model.animNext = null;
					}
				}
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