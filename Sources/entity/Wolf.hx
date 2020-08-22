package entity;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
using spriterkha.SpriterG2;

enum WolfState {
    Idle;
    Charge;
    Retreat;
}

class Wolf extends Entity {
    public var state:WolfState = Idle;
    public var targetPosition:Vector2 = new Vector2();
    var targetFollowSpeed = 5;
    var origin = new Vector2(250, 250);
    
    var entity:EntityInstance;
    var imageSheet:ImageSheet;
    
    var life = 0;
    
    override public function new(imageSheet:ImageSheet, spriter:Spriter) {
        super();
        position = new Vector2(500,800);

        entity = spriter.createEntity("enemy1");
        entity.play("run");
        entity.speed = 1.6;
        this.imageSheet = imageSheet;
    }
    
    override public function update(input:Input, level:Level) {
        entity.step(1/60);
        life++;
    }
    override public function render(g:Graphics) {
        var scale = .25;
        var size = new Vector2(500*scale,500*scale);
        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (-size.x / 2), position.y-size.y))
        .multmat(kha.math.FastMatrix3.scale(scale, scale)));
        g.color = kha.Color.White;
        g.drawSpriter(imageSheet, entity, 0, 0);
        g.popTransformation();
    }
}