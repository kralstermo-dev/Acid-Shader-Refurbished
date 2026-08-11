#version 330 compatibility

#define ACID_INTENSITY 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0]

#include "/common.glsl"

out vec4 color;
out vec2 texcoord;
out vec2 lmcoord;

void main() {
    vec4 p = gl_ModelViewMatrix * gl_Vertex;
    p = gbufferModelViewInverse * p;
    p = geomfunc(p);
    p = gbufferModelView * p;

    gl_Position = gl_ProjectionMatrix * p;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color    = gl_Color;
}