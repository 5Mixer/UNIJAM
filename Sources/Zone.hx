package ;
import differ.shapes.Polygon;
import kha.math.Vector2;

class Zone {
	public var position:Vector2;
	public var size:Vector2;
    public var type:String;
    public var collider:differ.shapes.Polygon;
	public function new(x:Int, y:Int, w:Int, h:Int, type:String) {
		this.position = new Vector2(x, y);
		this.size = new Vector2(w, h);
        this.type = type;
        collider = Polygon.rectangle(x,y,w,h,false);
	}
}