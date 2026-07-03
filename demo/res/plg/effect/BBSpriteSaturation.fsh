// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform lowp float saturation;

const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    lowp vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
    lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
    lowp vec3 greyScaleColor = vec3(luminance);
    
	gl_FragColor = vec4(mix(greyScaleColor, textureColor.rgb, saturation), textureColor.w);
    
}

