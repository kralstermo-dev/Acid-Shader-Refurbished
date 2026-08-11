#ifndef UNIFORMS_GLSL
#define UNIFORMS_GLSL

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 relativeEyePosition;
uniform vec3 eyePosition;
uniform vec3 playerLookVector;

uniform float frameTime;
uniform float frameTimeCounter;
uniform int worldTime;

#endif