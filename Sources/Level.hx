package ;

import differ.shapes.Shape;
import differ.shapes.Polygon;

class Level {
    public var colliders:Array<Shape> = [];
    public var tiled:Tiled;

    public function new(levelNumber) {
        tiled = new Tiled(switch levelNumber {
            case 1: kha.Assets.blobs.level1_tmx.toString();
            case 2: kha.Assets.blobs.level2_tmx.toString();
            default: "";
        });
        for (polygon in tiled.polygons){
            for (triangle in polygon.triangles) {
                var vertices = [];
                for (point in triangle.points)
                    vertices.push(new differ.math.Vector(point.x, point.y));

                colliders.push(new Polygon(0,0, vertices));
            }
        }
    }
    public function render(g:kha.graphics2.Graphics) {
        // Debug rendering of triangulated collisions
        for (polygon in tiled.polygons) {
            polygon.render(g);
        }
    }
}