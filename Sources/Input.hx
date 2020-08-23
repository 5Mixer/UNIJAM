package ;

import kha.input.MouseImpl;
import kha.math.Vector2;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;

class Input {
    public var left = false;
    public var right = false;
    public var onSoulSummon:(type: String)->Void;
    public var onJump:()->Void;
    public var onDespawn:()->Void;
    public var restart:()->Void;
    
    public var leftMouseDown = false;
    public var mousePosition: Vector2 = new Vector2();
    public var camera: Camera;

    public function new () {
        Keyboard.get().notify(keyDown, keyUp, null);
        Mouse.get().notify(mouseDown, mouseUp, mouseMove, null);
    }
    function keyDown(key:KeyCode) {
        if (key == KeyCode.W || key == KeyCode.Space && onJump != null) {
            onJump();
        }
        if (key == KeyCode.A || key == KeyCode.Left) {
            left = true;
        }
        if (key == KeyCode.D || key == KeyCode.Right) {
            right = true;
        }
        if (key == KeyCode.R) {
            restart();
        }
        if (key == KeyCode.One && onSoulSummon != null) {
            onSoulSummon("dagger");
        }
        if (key == KeyCode.Two && onSoulSummon != null) {
            onSoulSummon("axe");
        }
    }
    function keyUp(key:KeyCode) {
        if (key == KeyCode.A || key == KeyCode.Left) {
            left = false;
        }
        if (key == KeyCode.D || key == KeyCode.Right) {
            right = false;
        }
    }

    function mouseMove(x, y, dx, dy) {
        mousePosition = new Vector2(x,y);
    }

    public function getMousePosition() {
        return camera.viewToWorld(mousePosition);
    }
    function mouseDown(button, x, y) {
        if (button == 0)
            leftMouseDown = true;
    }
    function mouseUp(button, x, y) {
        if (button == 0)
            leftMouseDown = false;
    }
}