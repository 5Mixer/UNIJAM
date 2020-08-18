package rendering;

import kha.Image;

// An abstraction of g2 as a render pass, facilitating more complex render pipelines
class RenderPass {
    var drawers:Array<(pass:RenderPass)->Void> = [];
    public var passImage:Image;
    public function new() {
        passImage = Image.createRenderTarget(kha.Window.get(0).width, kha.Window.get(0).height);
    }
    public function pass() {
        passImage.g2.begin(true, kha.Color.fromBytes(0,0,0,0));
        for (drawer in drawers) {
            drawer(this);
        }
        passImage.g2.end();
    }
    public function registerRenderer(renderer:(pass:RenderPass)->Void) {
        drawers.push(renderer);
    }
    public function render(g:kha.graphics2.Graphics) {
        g.pushTransformation(kha.math.FastMatrix3.identity());
        g.drawImage(passImage, 0, 0);
        g.popTransformation();
    }
}