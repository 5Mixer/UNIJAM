package entity;

import kha.graphics2.Graphics;
import kha.math.Vector2;
import differ.shapes.Polygon;

class Entity {
    public var position:Vector2 = new Vector2();
    public function new() {}
    public function update(input:Input, level:Level) {}
    public function render(g:Graphics) {}
    public function getCollider():Polygon {return null;}
}