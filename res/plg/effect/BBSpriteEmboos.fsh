// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;

uniform vec4 substract;
uniform vec2 blurSize;

void main() {
    
    // 2
    vec2 onePixel = vec2(1.0 / 480.0, 1.0 / 320.0);
    
    // 3
    vec2 texCoord = v_texCoord;
    vec4 color;
    color.rgb = vec3(0.5);
    color -= texture2D(CC_Texture0, texCoord - onePixel) * 1.0;
    color += texture2D(CC_Texture0, texCoord + onePixel) * 1.0;
    
    // 5
    color.rgb = vec3((color.r + color.g + color.b) / 3.0);
    gl_FragColor = vec4(color.rgb, 1);
}

