// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform highp float threshold;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    highp vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
    highp float luminance = dot(textureColor.rgb, W);
    highp float thresholdResult = step(threshold, luminance);
    
    gl_FragColor = vec4(vec3(thresholdResult), textureColor.w);
}

