using Toybox.WatchUi as Ui;
using Toybox.Graphics;

module UI{
	class DirectionDrawable extends Ui.Drawable{
		var arrow;
		var center;
		var angle;
		var line;
		
		function initialize(_arrow, _center, _angle){
			arrow = _arrow;
			center = _center;
			angle = _angle;
			var d = 253;
			line = [[center[0], center[1] - d], [center[0], center[1] + d]];
		}
		
		hidden function getAngle(){
			var a = angle;
			if(a < 0){
				a = Math.PI * 2 + a;
			}
			if(a > Math.PI){
				return 2 * Math.PI - a;
			}
			return a;
		}
		
		hidden function getRoundCoord(dc){
			var r;
			var a = getAngle();
			var w = dc.getWidth() / 2;
			var a1 = Math.atan(w / center[1]);
			var a2 = Math.PI - Math.atan(w / (dc.getHeight() - center[1]));
			var a90 = Math.PI / 2;
			
			if(a > 0 && a <= a1){
				r = w / Math.sin(a);
			} else if(a <= a90){
				r = w / Math.cos(a90 - a);
			} else if(a <= a2){
				r = w / Math.cos(a - a90);
			} else {
				r = w / Math.sin(Math.PI - a);
			}
			
			r -= 4;
	        var x = center[0] + r * Math.sin(angle);
	        var y = center[1] - r * Math.cos(angle);
	        return [x, y];
	    }
		
		function draw(dc){
			dc.setPenWidth(2);
			UI.setColor(dc, COLOR_HIGHLIGHT);
			var p1 = rotate(line[0], center, angle);
			var p2 = rotate(line[1], center, angle);
			dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
			
			p1 = getRoundCoord(dc);
			UI.setColor(dc, Graphics.COLOR_RED);
			dc.fillCircle(p1[0], p1[1], 5);
			
			UI.setColor(dc, COLOR_SECONDARY);
			p1 = rotate(arrow[0], center, angle);
			p2 = rotate(arrow[1], center, angle);
			var p3 = rotate(arrow[2], center, angle);
			var p4 = rotate(arrow[3], center, angle);
			dc.fillPolygon([p1, p2, p3, p4]);
							
			dc.setPenWidth(3);
			UI.setColor(dc, COLOR_LOWLIGHT);
			dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
			dc.drawLine(p2[0], p2[1], p3[0], p3[1]);
			dc.drawLine(p3[0], p3[1], p4[0], p4[1]);
			dc.drawLine(p4[0], p4[1], p1[0], p1[1]);
		}
	}
}