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
			line = [[center[0], 0], [center[0], center[1]*2]];
		}
		
		hidden function getRoundCoord(dc, cx, cy, a, r){
			var r = dc.getHeight()/2;
			var d = center[1] - r;
			var bb = 2 * d * Math.cos(angle);
			var cc = d * d - r * r;
			var descr = bb * bb - 4 * cc;
			r = (bb + Math.sqrt(descr))/2 - 4;
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