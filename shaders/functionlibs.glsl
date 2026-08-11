#ifndef FUNCTIONLIBS_GLSL
#define FUNCTIONLIBS_GLSL

float pow2(float a) { return pow(2.0, a); }
vec2 pow2(vec2 a) { return vec2(pow(2.0, a.x), pow(2.0, a.y)); }
vec3 pow2(vec3 a) { return vec3(pow(2.0, a.x), pow(2.0, a.y), pow(2.0, a.z)); }
vec4 pow2(vec4 a) { return vec4(pow(2.0, a.x), pow(2.0, a.y), pow(2.0, a.z), pow(2.0, a.w)); }

float dot2(float a) { return a * a; }
float dot2(vec2 a) { return dot(a, a); }
float dot2(vec3 a) { return dot(a, a); }
float dot2(vec4 a) { return dot(a, a); }

float mix3(float a, float b, float c, float fac) { return mix(mix(a, b, fac), mix(b, c, fac), fac); }
vec2 mix3(vec2 a, vec2 b, vec2 c, float fac) { return mix(mix(a, b, fac), mix(b, c, fac), fac); }
vec3 mix3(vec3 a, vec3 b, vec3 c, float fac) { return mix(mix(a, b, fac), mix(b, c, fac), fac); }
vec4 mix3(vec4 a, vec4 b, vec4 c, float fac) { return mix(mix(a, b, fac), mix(b, c, fac), fac); }

float mix4(float a, float b, float c, float d, float fac) { return mix(mix(mix(a, b, fac), mix(b, c, fac), fac), mix(mix(b, c, fac), mix(c, d, fac), fac), fac); }
vec2 mix4(vec2 a, vec2 b, vec2 c, vec2 d, float fac) { return mix(mix(mix(a, b, fac), mix(b, c, fac), fac), mix(mix(b, c, fac), mix(c, d, fac), fac), fac); }
vec3 mix4(vec3 a, vec3 b, vec3 c, vec3 d, float fac) { return mix(mix(mix(a, b, fac), mix(b, c, fac), fac), mix(mix(b, c, fac), mix(c, d, fac), fac), fac); }
vec4 mix4(vec4 a, vec4 b, vec4 c, vec4 d, float fac) { return mix(mix(mix(a, b, fac), mix(b, c, fac), fac), mix(mix(b, c, fac), mix(c, d, fac), fac), fac); }

mat3 rotation3d(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(
        oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s, 
        oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c          
    );
}

vec2 rot(vec2 p, float a) { 
    return p.xy * mat2(cos(a), sin(a), -sin(a), cos(a)); 
}

vec3 inv(vec3 p, vec3 ofset) {
    p += ofset;
    p = normalize(p) * (dot2(ofset) / length(p));
    p = reflect(p, normalize(ofset));
    return p + ofset;
}

vec3 inv2(vec3 p, vec3 dpos) {
    return length(dpos) > 0.0001 ? inv(p, normalize(dpos) * (1.0 / length(dpos))) : p;
}

vec4 qmul(vec4 a, vec4 b) {
    return vec4(
        a.w * b.xyz + b.w * a.xyz + cross(a.xyz, b.xyz),
        a.w * b.w - dot(a.xyz, b.xyz) 
    );
}

vec4 qinv(vec4 a) {
    return normalize(a) * (1.0 / length(a));
}

vec3 qrot(vec3 pos, vec3 axis, float angle) {
    vec4 q = vec4(sin(angle / 2.0) * axis, cos(angle / 2.0));
    vec4 partial = qmul(q, vec4(pos, 0.0));
    return -partial.w * q.xyz + q.w * partial.xyz + cross(q.xyz, partial.xyz);
}

vec3 getm(mat3 matr) {
    return vec3(matr[0][0], matr[1][1], matr[2][2]);
}

#endif