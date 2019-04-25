
#version 330 core
in vec2 vposition;

out vec2 uv;



void main() {
    gl_Position =  vec4(vposition,0.0, 1.0);
    uv = (vposition + 1)/2;
}
