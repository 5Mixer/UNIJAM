#version 450

in vec3 pos;
in vec2 uv;

// Interpolated for each fragment
out vec2 vUV;

void main() {
    gl_Position = vec4(pos, 1.);
    vUV = uv;
}