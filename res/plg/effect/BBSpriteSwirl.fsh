// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;
uniform sampler2D CC_Texture0;

uniform highp vec2 center;
uniform highp float radius;
uniform highp float angle;

void main() {
    highp vec2 v_texCoordToUse = v_texCoord;
    highp float dist = distance(center, v_texCoord);
    v_texCoordToUse -= center;
    if (dist < radius) { highp float percent = (radius - dist) / radius;
        highp float theta = percent * percent * angle * 8.0;
        highp float s = sin(theta);
        highp float c = cos(theta);
        v_texCoordToUse = vec2(dot(v_texCoordToUse, vec2(c, -s)), dot(v_texCoordToUse, vec2(s, c)));
    }
    v_texCoordToUse += center;
    gl_FragColor = texture2D(CC_Texture0, v_texCoordToUse );
}

