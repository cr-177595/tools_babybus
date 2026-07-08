// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;
uniform sampler2D CC_Texture0;

uniform lowp float contrast;

void main()
{
    lowp vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
    gl_FragColor = vec4(((textureColor.rgb - vec3(0.5)) * contrast + vec3(0.5)), textureColor.w);
}

