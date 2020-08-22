package entity;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
using spriterkha.SpriterG2;

enum BatState {
    Idle;
    Charge;
    Retreat;
}

class Bat extends Entity {
    public var state:BatState = Idle;
    public var targetPosition:Vector2 = new Vector2();
    var idleTargetPosition:Vector2 = new Vector2();
    var targetFollowSpeed = 5;
    var origin = new Vector2(260, 280);
    var targetOffset = new Vector2(0, 100);
    
    var entity:EntityInstance;
    var imageSheet:ImageSheet;
    
    var life = 0;
    
    override public function new(imageSheet:ImageSheet, spriter:Spriter) {
        super();

        entity = spriter.createEntity("enemy2");
        entity.play("fly");
        entity.speed = 1.6;
        this.imageSheet = imageSheet;
    }
    
    override public function update(input:Input, level:Level) {
        entity.step(1/60);
        life++;
        if (state == Idle) {
            var angle = life/100*(Math.PI*2);
            var radius = 200;
            idleTargetPosition = targetPosition.add(new Vector2(Math.cos(angle)*radius, Math.sin(angle)*radius)).sub(targetOffset);
            position = position.add(idleTargetPosition.sub(position).normalized().mult(targetFollowSpeed));
        }
    }
    override public function render(g:Graphics) {
        var scale = .5;
        var size = new Vector2(500,500);
        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (-size.x / 2), position.y-size.y))
        .multmat(kha.math.FastMatrix3.scale(scale, scale)));
        g.color = kha.Color.White;
        g.drawSpriter(imageSheet, entity, 0, 0);
        
        g.popTransformation();
    }
}