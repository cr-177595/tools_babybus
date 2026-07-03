// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying highp vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform highp vec2 center;
uniform highp float radius;
uniform highp float scale;

void main() {
    highp vec2 v_texCoordToUse = v_texCoord;
    highp float dist = distance(center, v_texCoord);
    v_texCoordToUse -= center;
	if (dist < radius) {
		highp float percent = 1.0 - ((radius - dist) / radius) * scale;
		percent = percent * percent; v_texCoordToUse = v_texCoordToUse * percent;
	}
	v_texCoordToUse += center;
	gl_FragColor = texture2D(CC_Texture0, v_texCoordToUse );
}

