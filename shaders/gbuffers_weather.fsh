#version 330 compatibility

uniform sampler2D texture;
uniform sampler2D lightmap;

in vec4 color;
in vec2 texcoord;
in vec2 lmcoord;

void main() {
    vec4 texColor = texture2D(texture, texcoord) * color;
    vec4 lightColor = texture2D(lightmap, lmcoord);
    gl_FragColor = texColor * lightColor;
}