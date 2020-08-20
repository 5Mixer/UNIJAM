#version 450

in vec2 vUV;

// Constant across mesh
uniform sampler2D textureSampler;
uniform sampler2D maskTextureSampler;
uniform mat3 transform;

out vec4 fragColor;

// Alpha of mask decides alpha of output
// Red of mask decides colour, between a and b, where a is the source texture
void main() {
    vec2 xy = (transform * vec3(gl_FragCoord.xy, 1)).xy;

    vec4 a = texture(textureSampler, vUV); 
    vec4 b = vec4(1.0, 1.0, 1.0, 0.0);
    
    float control = texture(maskTextureSampler, vUV).r;
    float alpha = texture(maskTextureSampler, vUV).a;

    vec4 colour = a * (1 - control) + b * control;

    // fragColor = vec4(colour.r, colour.g, colour.b, alpha);

    // by taking the minimum of inverse control and alpha, white and alpha both create transparency.
    // fragColor = vec4(colour.r, colour.g, colour.b, min(1.0-control, alpha));
    fragColor = vec4(colour.r, colour.g, colour.b, alpha);
}