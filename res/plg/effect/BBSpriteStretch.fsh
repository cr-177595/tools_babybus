// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying highp vec2 v_texCoord;
uniform sampler2D CC_Texture0;
uniform highp vec2 center;

void main() {
	highp vec2 normCoord = 2.0 * v_texCoord - 1.0;
	highp vec2 normCenter = 2.0 * center - 1.0;
	normCoord -= normCenter;
	mediump vec2 s = sign(normCoord);
	normCoord = abs(normCoord);
	normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
	normCoord = s * normCoord;
	normCoord += normCenter;
	mediump vec2 v_texCoordToUse = normCoord / 2.0 + 0.5;
	gl_FragColor = texture2D(CC_Texture0, v_texCoordToUse );
}

