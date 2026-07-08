// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;
uniform sampler2D CC_Texture0;

uniform highp float red;
uniform highp float green;
uniform highp float blue;

void main()
{
    highp vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
    
    gl_FragColor = vec4(textureColor.r * red, textureColor.g * green, textureColor.b * blue, 1.0);
}

