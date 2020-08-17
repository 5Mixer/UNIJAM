package ;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;

class Input {
    public var left = false;
    public var right = false;
    public var onJump:()->Void;

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
    }
    function keyUp(key:KeyCode) {
        if (key == KeyCode.A || key == KeyCode.Left) {
            left = false;
        }
        if (key == KeyCode.D || key == KeyCode.Right) {
            right = false;
        }
    }

    function mouseMove(x, y, dx, dy) {}
    function mouseDown(button, x, y) {}
    function mouseUp(button, x, y) {}
}