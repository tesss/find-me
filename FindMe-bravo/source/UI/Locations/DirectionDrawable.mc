using Toybox.WatchUi as Ui;

module UI{
	class DirectionDrawable extends Ui.Drawable{
		var arrow;
		var center;
		var angle;
		
		function initialize(_arrow, _center, _angle){
			arrow = _arrow;
			center = _center;
			angle = _angle;
		}
		
		function draw(dc){
			UI.setColor(dc, COLOR_SECONDARY);
			var p1 = rotate(arrow[0], center, angle);
			var p2 = rotate(arrow[1], center, angle);
			var p3 = rotate(arrow[2], center, angle);
			var p4 = rotate(arrow[3], center, angle);
			dc.fillPolygon([p1, p2, p3, p4]);
							
			UI.setColor(dc, COLOR_LOWLIGHT);
			dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
			dc.drawLine(p2[0], p2[1], p3[0], p3[1]);
			dc.drawLine(p3[0], p3[1], p4[0], p4[1]);
			dc.drawLine(p4[0], p4[1], p1[0], p1[1]);
		}
	}
}