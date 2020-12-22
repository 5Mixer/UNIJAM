package entity.soul;

import kha.math.Vector2;
import differ.shapes.Polygon;

class Soul extends Entity {
    public var targetPosition:Vector2 = new Vector2();
    public var thrower: Player;
    var mousePosition: Vector2;
    public var isColliding = false;

    public function new(position: Vector2) {
        super();
        this.position = position;
    }

    override public function update(input: Input, level:Level) {
        mousePosition = input.getMousePosition();
    }

    public function isActive() {
        return true;
    }

    public function deactivate() {}
}