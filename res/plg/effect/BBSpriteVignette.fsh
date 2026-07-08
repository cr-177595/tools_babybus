// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;
uniform sampler2D CC_Texture0;

uniform highp float vignetteStart;
uniform highp float vignetteEnd;

void main()
{
    lowp vec3 rgb = texture2D(CC_Texture0, v_texCoord).rgb;
    lowp float d = distance(v_texCoord, vec2(0.5,0.5));
    rgb *= smoothstep(vignetteEnd, vignetteStart, d);
    gl_FragColor = vec4(vec3(rgb),1.0);
}

