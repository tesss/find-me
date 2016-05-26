using Toybox.WatchUi as Ui;
using Toybox.Position;
using Toybox.ActivityRecording as A;
using Data;

module UI{
	class SettingsPicker extends Ui.Picker {
		function initialize(){
			var interval = dataStorage.getInterval();
			interval = Data.ArrayExt.indexOf(IntervalPickerFactory.values, interval, method(:predicate));
			var distance = dataStorage.getDistance();
			distance = Data.ArrayExt.indexOf(DistancePickerFactory.values, distance, method(:predicate));
			var format = dataStorage.getFormat();
			format = Data.ArrayExt.indexOf(FormatPickerFactory.values, format, method(:predicate));
			var type = dataStorage.getActivityType();
			type = Data.ArrayExt.indexOf(TypePickerFactory.values, type, method(:predicate));
			var sorting = dataStorage.getSortBy();
			sorting = Data.ArrayExt.indexOf(SortingPickerFactory.values, sorting, method(:predicate));
			setOptions({
				:title => getText("Settings", {:isSettings => true, :isTitle => true}), 
				:pattern => [
					getText("Int.", {:isSettings => true}),
					new IntervalPickerFactory(),
					getText(""),
					getText("Dist.", {:isSettings => true}),
					new DistancePickerFactory(),
					getText(""),
					getText("Format", {:isSettings => true}),
					new FormatPickerFactory(),
					getText(""),
					getText("Type", {:isSettings => true}),
					new TypePickerFactory(),
					getText(""),
					getText("Sort", {:isSettings => true}),
					new SortingPickerFactory()
				],
				:defaults => [
					null,
					interval,
					null,
					null,
					distance,
					null,
					null,
					format,
					null,
					null,
					type,
					null,
					null,
					sorting,
					null
				]
			});
		}
		
	    function onUpdate(dc) {
	        clearPicker(dc);
	    }
		
		function predicate(a, b){
			return a == b;
		}
	}
	
	class SettingsPickerDelegate extends Ui.PickerDelegate {
		function onAccept(values){
			dataStorage.setInterval(values[1]);
			dataStorage.setDistance(values[4]);
			dataStorage.setFormat(values[7]);
			dataStorage.setActivityType(values[10]);
			dataStorage.setSortBy(values[13]);
			Ui.popView(transition);
			pushInfoView("Settings saved", null, false);
		}
		
		function onCancel(){
			Ui.popView(transition);
		}
	}
	
	class IntervalPickerFactory extends Ui.PickerFactory {
		static const values = [0, 1, 5, 10, 30, 60, 300, -1];
		
		function getDrawable(index, isSelected){
			var value = values[index];
			if(value == -1){
				value = "Disable";
			} else if(value == 0){
				value = "Contin.";
			} else if (value < 60){
				value = value + " sec";
			} else{
				value = value/60 + " min";
			}
			return getText(value, {:isSelected => isSelected, :isSettings => true});
		}
		
		function getSize(){
			return values.size();
		}
		
		function getValue(index){ 
			return values[index];
		}
	}
	
	class DistancePickerFactory extends Ui.PickerFactory {
		static const values = [0, 0.1, 0.5, 1, 2, 5, 10, 50, 100];
		
		function getDrawable(index, isSelected){
			var value = values[index];
			if(value == 0){
				value = "Disable";
			} else if(value < 1){
				value = (value*1000).toNumber() + " m"; // add imperial units
			} else {
				value = value + " km";
			}
			return getText(value, {:isSelected => isSelected, :isSettings => true});
		}
		
		function getSize(){
			return values.size();
		}
		
		function getValue(index){ 
			return values[index];
		}
	}
	
	class FormatPickerFactory extends Ui.PickerFactory {
		static const values = [Position.GEO_DEG, Position.GEO_DM, Position.GEO_DMS, Position.GEO_MGRS];
		
		function getDrawable(index, isSelected){
			var value = values[index];
			if(value == Position.GEO_DEG){
				value = "D.D";
			} else if(value == Position.GEO_DM){
				value = "D M.M'";
			} else if(value == Position.GEO_DMS){
				value = "D M' S\"";
			} else if(value == Position.GEO_MGRS){
				value = "MGRS";
			}
			return getText(value, {:isSelected => isSelected, :isSettings => true});
		}
		
		function getSize(){
			return values.size();
		}
		
		function getValue(index){ 
			return values[index];
		}
	}
	
	class TypePickerFactory extends Ui.PickerFactory {
		static const values = [
			A.SPORT_GENERIC, 
			A.SPORT_ALPINE_SKIING, 
			A.SPORT_CROSS_COUNTRY_SKIING,
			A.SPORT_CYCLING,
			A.SPORT_HIKING,
			A.SPORT_MOUNTAINEERING,
			A.SPORT_MULTISPORT,
			A.SPORT_PADDLING,
			A.SPORT_ROWING,
			A.SPORT_RUNNING,
			A.SPORT_SNOWBOARDING,
			A.SPORT_SWIMMING,
			A.SPORT_TRAINING,
			A.SPORT_TRANSITION,
			A.SPORT_WALKING
		];
		
		function getDrawable(index, isSelected){
			var value = values[index];
			if(value == A.SPORT_GENERIC){
				value = "Generic";
			} else if(value == A.SPORT_ALPINE_SKIING){
				value = "Alp Ski";
			} else if(value == A.SPORT_CROSS_COUNTRY_SKIING){
				value = "Cr. Ski";
			} else if(value == A.SPORT_CYCLING){
				value = "Cycle";
			} else if(value == A.SPORT_HIKING){
				value = "Hike";
			} else if(value == A.SPORT_MOUNTAINEERING){
				value = "Mount.";
			} else if(value == A.SPORT_MULTISPORT){
				value = "Multi.";
			} else if(value == A.SPORT_PADDLING){
				value = "Paddle";
			} else if(value == A.SPORT_ROWING){
				value = "Row";
			} else if(value == A.SPORT_RUNNING){
				value = "Run";
			} else if(value == A.SPORT_SNOWBOARDING){
				value = "Board";
			} else if(value == A.SPORT_SWIMMING){
				value = "Swim";
			} else if(value == A.SPORT_TRAINING){
				value = "Train.";
			} else if(value == A.SPORT_TRANSITION){
				value = "Trans.";
			} else if(value == A.SPORT_WALKING){
				value = "Walk";
			}
			return getText(value, {:isSelected => isSelected, :isSettings => true});
		}
		
		function getSize(){
			return values.size();
		}
		
		function getValue(index){ 
			return values[index];
		}
	}
	
	class SortingPickerFactory extends Ui.PickerFactory {
		static const values = [Data.SORTBY_DISTANCE, Data.SORTBY_NAME];
		
		function getDrawable(index, isSelected){
			var value = values[index];
			if(value == Data.SORTBY_DISTANCE){
				value = "Dist.";
			} else if(value == Data.SORTBY_NAME){
				value = "Name";
			}
			return getText(value, {:isSelected => isSelected, :isSettings => true});
		}
		
		function getSize(){
			return values.size();
		}
		
		function getValue(index){ 
			return values[index];
		}
	}
}