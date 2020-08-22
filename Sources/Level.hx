package ;

import differ.shapes.Shape;
import differ.shapes.Polygon;

class Level {
    public var colliders:Array<Shape> = [];
    var tiled:Tiled;

    public function new() {
        tiled = new Tiled(kha.Assets.blobs.level1_tmx.toString());
        for (triangle in tiled.entities[0].triangles) {
            var vertices = [];
            for (point in triangle.points)
                vertices.push(new differ.math.Vector(point.x, point.y));

            colliders.push(new Polygon(0,0, vertices));
        }
    }
    public function render(g:kha.graphics2.Graphics) {
        // Debug rendering of triangulated collisions
        tiled.entities[0].render(g);
    }
}