// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform sampler2D CC_Texture1;

void main() {
    vec3 texel = texture2D(CC_Texture0, v_texCoord).rgb;
    texel = vec3(dot(vec3(0.3, 0.6, 0.1), texel));
    texel = vec3(texture2D(CC_Texture1, vec2(texel.r, .16666)).r);
    gl_FragColor = vec4(texel, 1.0);    
}

