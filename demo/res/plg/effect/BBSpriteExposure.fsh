// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;
uniform sampler2D CC_Texture0;

uniform lowp float exposure;

void main()
{
    highp vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
    gl_FragColor = vec4(textureColor.rgb * pow(2.0, exposure), textureColor.w);
}

