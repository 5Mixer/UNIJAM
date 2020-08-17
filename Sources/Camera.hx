package ;

import kha.Window;
import kha.math.FastMatrix3;
import kha.math.Vector2;
import kha.graphics2.Graphics;

class Camera {
	public var position:Vector2;
	public var scale:Float;

	public function new () {
		position = new Vector2();
		scale = 1;
	}
	public function zoomOn(screenPoint:Vector2, amount:Float) {
		var oldWorldPos = viewToWorld(screenPoint);
		if (amount < 0) {
			scale *= -amount;
		} else {
			scale /= amount;
		} 
		scale = Math.max(0.005, Math.min(5, scale));
		var newWorldPos = viewToWorld(screenPoint);
		position = position.add(worldToView(oldWorldPos).sub(worldToView(newWorldPos)));
	}
	public function worldToView(point:Vector2) {
		return point.mult(scale).sub(position);
	}
	public function viewToWorld(point:Vector2) {
		return point.add(position).mult(1/scale);
	}
	public function getTransformation() {
		return FastMatrix3.translation(-(position.x), -(position.y)).multmat(FastMatrix3.scale(scale, scale));
	}
	public function transform (g:Graphics) {
		g.pushTransformation(getTransformation());
	}
	public function reset (g:Graphics) {
		g.popTransformation();
	}
	public function getScreenBoundsWorldSpace(){
		return {
			topLeft: viewToWorld(new Vector2()),
			bottomRight: viewToWorld(new Vector2(Window.get(0).width, Window.get(0).height)),
		};
	}
}
