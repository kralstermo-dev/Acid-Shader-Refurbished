#ifndef COMMON_GLSL
#define COMMON_GLSL

#ifndef ACID_INTENSITY
#define ACID_INTENSITY 1.0
#endif

// ==========================================
// UNIFORMS
// ==========================================
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

// ==========================================
// FUNCTION LIBRARIES
// ==========================================
float pow2(float a) { return pow(2.0, a); }
float dot2(float a) { return a * a; }
float dot2(vec3 a) { return dot(a, a); }

vec2 rot(vec2 p, float a) { 
    return p.xy * mat2(cos(a), sin(a), -sin(a), cos(a)); 
}

vec3 inv(vec3 p, vec3 ofset) {
    p += ofset;
    p = normalize(p) * (dot2(ofset) / length(p));
    p = reflect(p, normalize(ofset));
    return p + ofset;
}

vec4 qmul(vec4 a, vec4 b) {
    return vec4(
        a.w * b.xyz + b.w * a.xyz + cross(a.xyz, b.xyz),
        a.w * b.w - dot(a.xyz, b.xyz) 
    );
}

// ==========================================
// CUSTOM WARP MATH (Direct Scaling for High Intensity)
// ==========================================
const float E = 2.718281828459045;
const float PI = 3.14159265359;

vec3 cust1(vec3 p, vec3 vel, vec3 cam, vec3 eye, float d, float J, float x, float y, float z, float t, float X, float Y, float Z){
    float distanceSquared = p.x * p.x + p.z * p.z;
    float distNear = length(p.xz);
    float timeTicks = float(worldTime);

    // Distance Fade: keeps ground under feet steady (0-5 blocks)
    float nearFade = clamp(distNear / 15.0, 0.05, 1.0);

    // Base waves
    float waveNear = sin(distNear * 0.4 - timeTicks * 0.05) * 0.5;
    float waveFar = sin(distanceSquared * sin(timeTicks / 143.0) / 1000.0) * 3.0;

    // Direct linear height scaling
    p.y += (waveNear + waveFar) * nearFade * ACID_INTENSITY;

    // Horizontal warping that scales aggressively with higher intensity settings
    float horizontalWarp = sin(p.y * 0.2 + timeTicks * 0.05) * (ACID_INTENSITY * 0.8);
    p.x += horizontalWarp * nearFade;
    p.z += horizontalWarp * nearFade;

    // Angle rotation (clamped to prevent 360-degree inversion loop)
    float omFar = sin(distanceSquared * sin(timeTicks / 256.0) / 5000.0) * sin(timeTicks / 200.0) * 0.2;
    float om = omFar * nearFade * clamp(ACID_INTENSITY, 0.1, 2.5);

    float curY = p.y;
    float curX = p.x;
    p.y = curX * sin(om) + curY * cos(om);
    p.x = curX * cos(om) - curY * sin(om);

    return p;
}

vec3 torusify(vec3 p, vec3 cam, float J){
    float K = J / 2.0;
    p.y = tanh((p.y - cam.y) / K) * K;
    p.y -= K;

    p.xy = vec2(-sin(p.x * PI / J) * p.y, cos(p.x * PI / J) * p.y) + vec2(0.0, K);
    p.y += K;
    p.zy = vec2(sin(p.z * PI / J) * p.y, cos(p.z * PI / J) * p.y) - vec2(0.0, K);
    return p;
}

vec3 cust2(vec3 p, vec3 vel, vec3 cam, vec3 eye, float d, float J, float x, float y, float z, float t, float X, float Y, float Z){
    p = torusify(p + cam, cam, J) - torusify(cam, cam, J);

    vec3 vx = normalize(torusify(cam + vec3(0.01, 0.0, 0.0), cam, J) - torusify(cam, cam, J));
    vec3 vy = normalize(torusify(cam + vec3(0.0, 0.01, 0.0), cam, J) - torusify(cam, cam, J));
    vec3 vz = normalize(torusify(cam + vec3(0.0, 0.01, 0.0), cam, J) - torusify(cam, cam, J));
    mat3 dirc = mat3(vx, vy, vz);
    p = inverse(dirc) * p;
    return p;
}

vec3 cust3(vec3 p, vec3 vel, vec3 cam, vec3 eye, float d, float J, float x, float y, float z, float t, float X, float Y, float Z){
    float a = (sin(t / 6.0) * d) / J;

    mat3 NIL = mat3(
        cos(a), 0.0, -sin(a),
        0.0,    1.0,  0.0,
        sin(a), 0.0,  cos(a)
    );

    return p * NIL;
}

#define MODE 7
#define J 16
#define f5_distance 1

vec4 geomfunc(vec4 P){
    vec3 cam = eyePosition;
    vec3 eye = relativeEyePosition;
    vec3 p = P.xyz + eye;
    
    vec3 dpos = (cameraPosition - previousCameraPosition) / max(frameTime, 0.001);
    float x = p.x, y = p.y, z = p.z, w = P.w, t = frameTimeCounter;
    float X = x + cameraPosition.x, Y = y + cameraPosition.y, Z = z + cameraPosition.z;
    float d = length(p.xyz) / float(J);

    vec2 o = rot(vec2(float(J), 0.0), frameTimeCounter);

    mat3 SOLV = mat3(
        pow(2.0, -y / float(J)), 0.0, 0.0,
        x / float(J),           1.0, -z / float(J),
        0.0,                     0.0, pow(2.0, y / float(J))
    );

    switch (MODE){
        case 0: p = inv(p, vec3(o.y, 0.0, o.x)); break;
        case 1: p = inv(p, vec3(o.x, o.y, 0.0)); break;
        case 2: p = inv(p, vec3(0.0, o.x, o.y)); break;
        case 3: p += dpos * d / float(J); break;
        case 4: p = inv(p, vec3(0.0, float(J), 0.0)); break;
        case 5: p = inv(p, vec3(0.0, -float(J), 0.0)); break;
        case 6: p = p * SOLV; break;
        case 7: p = cust1(p, dpos, cam, eye, length(p.xyz), float(J), x, y, z, t, X, Y, Z); break;
        case 8: p = cust2(p, dpos, cam, eye, length(p.xyz), float(J), x, y, z, t, X, Y, Z); break;
        case 9: p = cust3(p, dpos, cam, eye, length(p.xyz), float(J), x, y, z, t, X, Y, Z); break;
        default: break;
    }

    return vec4(p - (eye * float(f5_distance)), P.w);
}

#endif