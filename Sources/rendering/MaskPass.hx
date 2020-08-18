package rendering;

import kha.graphics5_.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.BlendingFactor;
import kha.Window;
import kha.Image;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.math.FastMatrix3;
import kha.System;
import kha.Image;
import kha.Shaders;
import kha.Assets;
import kha.graphics5_.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.Graphics;
using kha.graphics2.GraphicsExtension;

class MaskPass extends RenderPass {
    public var image:Image;
    public var mask:Image;
    
    var vertices:Array<Float>;
    var uv:Array<Float>;
    var indices:Array<Int>;

    var vertexBuffer:VertexBuffer;
    var indexBuffer:IndexBuffer;
    var pipeline:PipelineState;

    var textureId:TextureUnit;
    var maskId:TextureUnit;
    var transformId:ConstantLocation;

    override public function new() {
        super();
        
        vertices = [
            -1., -1., 0., // 0: Top left
             1., -1., 0., // 1: Top right
            -1.,  1., 0., // 2: Bottom left
             1.,  1., 0.  // 3: Bottom right
        ];
        uv = [
            0., 0.,
            1., 0.,
            0., 1.,
            1., 1.,
        ];
        indices = [
            0, 1, 2,
            1, 2, 3
        ];

        var structure = new VertexStructure();
        structure.add('pos', VertexData.Float3);
        structure.add('uv', VertexData.Float2);
        var structureLength = 5;

        pipeline = new PipelineState();
        pipeline.inputLayout = [structure];

        pipeline.blendSource = BlendingFactor.SourceAlpha;
        pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;

        pipeline.fragmentShader = Shaders.mask_frag;
        pipeline.vertexShader = Shaders.passthrough_vert;
        pipeline.compile();
        
        textureId = pipeline.getTextureUnit('textureSampler');
        maskId = pipeline.getTextureUnit('maskTextureSampler');
        transformId = pipeline.getConstantLocation('transform');

        vertexBuffer = new VertexBuffer(4, structure, StaticUsage);
        var vertexBufferData = vertexBuffer.lock();
        for (i in 0...Std.int(vertexBufferData.length/structureLength)) {
            vertexBufferData.set(i * structureLength+0, vertices[i*3+0]);
            vertexBufferData.set(i * structureLength+1, vertices[i*3+1]);
            vertexBufferData.set(i * structureLength+2, vertices[i*3+2]);
            vertexBufferData.set(i * structureLength+3, uv[i*2+0]);
            vertexBufferData.set(i * structureLength+4, uv[i*2+1]);
        }
        vertexBuffer.unlock();

        indexBuffer = new IndexBuffer(indices.length, StaticUsage);
        var indexBufferData = indexBuffer.lock();
        for (i in 0...indexBufferData.length) {
            indexBufferData.set(i, indices[i]);
        }
        indexBuffer.unlock();

    }
    override public function pass() {
        passImage.g4.begin();
        passImage.g4.clear(kha.Color.fromBytes(0, 0, 0, 0));
        passImage.g4.setPipeline(pipeline);
        passImage.g4.setVertexBuffer(vertexBuffer);
        passImage.g4.setIndexBuffer(indexBuffer);
        // passImage.g4.setMatrix3(transformId, transformation.inverse());
        passImage.g4.setMatrix3(transformId, kha.math.FastMatrix3.identity());
        passImage.g4.setTexture(textureId, image);
        passImage.g4.setTexture(maskId, mask);
        passImage.g4.drawIndexedVertices();
        passImage.g4.end();
    }
}