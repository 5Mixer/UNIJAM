package entity;

import kha.Scheduler;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
using spriterkha.SpriterG2;
import differ.shapes.Polygon;
import differ.shapes.Shape;

enum BatState {
    Idle;
    Charge;
    Retreat;
}

class Bat extends Entity {
    public var state:BatState = Idle;
    public var targetPosition:Vector2 = new Vector2();
    var targetFollowSpeed = 5;
    var origin = new Vector2(260, 280);
    var idlePosition = new Vector2(500,500);
    var targetOffset = new Vector2(0, 100);
    
    var entity:EntityInstance;
    var imageSheet:ImageSheet;
    
    var chargeTime = 0;
    var player:Player;

    var scale = .5;
    var size:Vector2;
    var collisionScale = 0.6;
    
    override public function new(player, imageSheet:ImageSheet, spriter:Spriter, position:Vector2) {
        super();
        this.player = player;
        this.position = position;
        idlePosition = position.mult(1); // Clone vector
        size = new Vector2(500*scale,500*scale);

        entity = spriter.createEntity("enemy2");
        entity.play("fly");
        entity.speed = 1.6;
        this.imageSheet = imageSheet;
    }
    
    override public function update(input:Input, level:Level) {
        entity.step(1/60);
        if (state == Idle) {
            entity.speed = 1.5;
            position.y += Math.sin(Scheduler.realTime()*2)*1.0;
            position.x += Math.cos(Scheduler.realTime()*5)*.5;
            if (player.position.sub(position).length < 1200) {
                chargeTime++;
                if (chargeTime > 3*60 && entity.progress < .1) {
                    chargeTime = 0;

                    targetPosition.x = player.position.x;
                    targetPosition.y = player.position.y;

                    state = Charge;
                }
            }else{
                chargeTime = 0;
            }
        }else if(state == Charge) {
            var speed = 8+Math.sqrt(targetPosition.sub(position).length) * .6;
            position = position.add(targetPosition.sub(position).normalized().mult(speed));

            if (player.position.sub(position).length > 200 && player.position.sub(position).length < 1000) {
                targetPosition.x = player.position.x;
                targetPosition.y = player.position.y;
            }

            entity.speed = entity.progress < .2 ? .2 : 1;
            if (targetPosition.sub(position).length < 10) {
                state = Retreat;
            }
        }else if(state == Retreat) {
            entity.speed = 2;
            var speed = Math.sqrt(idlePosition.sub(position).length) * .8;
            position = position.add(idlePosition.sub(position).normalized().mult(speed));
            if (idlePosition.sub(position).length < 50) {
                state = Idle;
            }

        }
    }
    override public function getCollider() {
        return Polygon.rectangle(position.x - (size.x * .5) + size.x * (1 - collisionScale) / 2, 
        position.y - (size.y) + size.y * (1 - collisionScale) / 2, size.x * collisionScale, size.y * collisionScale, false);
    }
    
    override public function render(g:Graphics) {
        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (-size.x / 2), position.y-size.y))
        .multmat(kha.math.FastMatrix3.scale(scale, scale)));
        g.color = kha.Color.White;
        g.drawSpriter(imageSheet, entity, 0, 0);
        g.popTransformation();
    }
}