using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Data;
using _;

module UI{
	class LocationRoundDrawable extends Ui.Drawable{
		hidden var name;
		hidden var type;
		hidden var distance;
		hidden var bearing;
		hidden var showArrows;
		hidden var h;
		hidden var w;
		
		hidden var wc;
		hidden var hc;
		hidden var hc3;
		
		function initialize(options){
			h = options.get(:height);
			w = options.get(:width);
			setSize(w, h);
			name = options.get(:name);
			type = options.get(:type);
			distance = options.get(:distance);
			bearing = options.get(:bearing);
			showArrows = options.get(:showArrows);
			
			wc = w / 2;
			hc = h / 2;
			hc3 = hc / 3;
		}
		
		hidden function drawDynamic(dc){
			UI.setColor(dc, UI.COLOR_HIGHLIGHT);
			dc.drawText(wc, hc3 * 5 - 5, Graphics.FONT_MEDIUM, distance, Graphics.TEXT_JUSTIFY_CENTER);
			UI.setColor(dc, UI.COLOR_SECONDARY);
			if(bearing == null){
				dc.drawText(wc, hc3 * 3, Graphics.FONT_MEDIUM, "...", Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				var t1 = 0.9;
				var t2 = 0.5;
				var t3 = 0.65;
				var r = UI.DSIZE;
				var c = [wc, hc + r * t3];
				var p1 = [c[0], c[1] - r];
				var p2 = [c[0] + r * t1, c[1] + r];
				var p3 = [c[0] - r * t1, c[1] + r];
				var p4 = [c[0], c[1] + r * t2];
				c = [(p1[0] + p2[0] + p3[0]) / 3, (p1[1] + p2[1] + p3[1]) / 3];
				p1 = UI.rotate(p1, c, bearing);
				p2 = UI.rotate(p2, c, bearing);
				p3 = UI.rotate(p3, c, bearing);
				p4 = UI.rotate(p4, c, bearing);
				dc.fillPolygon([p1, p2, p4, p3]);
				UI.setColor(dc, UI.COLOR_SECONDARY);
				dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
				dc.drawLine(p2[0], p2[1], p4[0], p4[1]);
				dc.drawLine(p4[0], p4[1], p3[0], p3[1]);
				dc.drawLine(p3[0], p3[1], p1[0], p1[1]);
			}
		}
		
		function draw(dc){
			if(name != null && type != null){
				UI.setColor(dc, UI.COLOR_PRIMARY);
				dc.clear();				
				dc.drawText(wc, hc3, Graphics.FONT_MEDIUM, name, Graphics.TEXT_JUSTIFY_CENTER);
				
				UI.setColor(dc, UI.COLOR_LOWLIGHT);
				var padding = 20;
				dc.drawLine(padding, hc + UI.DSIZE, wc - UI.DSIZE - padding, hc);
				dc.drawLine(wc + UI.DSIZE + padding, hc, w - padding, hc + UI.DSIZE);
				
				UI.setColor(dc, UI.COLOR_SECONDARY);
				dc.drawText(wc, hc3 * 2, Graphics.FONT_TINY, type, Graphics.TEXT_JUSTIFY_CENTER);
			}
			if(showArrows == true){
				UI.setColor(dc, UI.COLOR_LOWLIGHT);
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
			if(distance != null){
				drawDynamic(dc);
			}
		}
	}
}