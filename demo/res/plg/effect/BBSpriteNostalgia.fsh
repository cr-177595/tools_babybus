#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_color;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform lowp float intensity;

void main(void) {
    lowp mat4 colorMatrix = mat4(0.3588, 0.7044, 0.1368, 0.0,
                                 0.2990, 0.5870, 0.1140, 0.0,
                                 0.2392, 0.4696, 0.0912 ,0.0,
                                 0,0,0,1.0);
    
    lowp vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
	lowp vec4 outputColor = textureColor * colorMatrix;
	gl_FragColor = (intensity * outputColor) + ((1.0 - intensity) * textureColor);
}