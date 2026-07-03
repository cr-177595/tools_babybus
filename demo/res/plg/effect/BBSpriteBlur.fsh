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
    
    if(substract.x > 0.0) {
	    vec4 sum = vec4(0.0);
	    vec2 offset;
	    float weight;
	    float squareX;
	    
	    for(float dx = 0.0; dx <= substract.x; dx += 1.0) {
	        squareX = dx * dx;
	        weight = substract.z * exp(squareX * substract.y);
	        
	        offset.x = -dx * blurSize.x;
	        offset.y = 0.0;
	        sum += texture2D(CC_Texture0, v_texCoord + offset) * weight;
	        
	        offset.x = dx * blurSize.x;
	        sum += texture2D(CC_Texture0, v_texCoord + offset) * weight;
	        
	        for(float dy = 1.0; dy <= substract.x; dy += 1.0) {
	            weight = substract.z * exp((squareX + dy * dy) * substract.y);
	            
	            offset.x = -dx * blurSize.x;
	            offset.y = -dy * blurSize.y;
	            sum += texture2D(CC_Texture0, v_texCoord + offset) * weight;
	            
	            offset.y = dy * blurSize.y;
	            sum += texture2D(CC_Texture0, v_texCoord + offset) * weight;
	            
	            offset.x = dx * blurSize.x;
	            sum += texture2D(CC_Texture0, v_texCoord + offset) * weight;
	            
	            offset.y = -dy * blurSize.y;
	            sum += texture2D(CC_Texture0, v_texCoord + offset) * weight;
	        }
	    }
	    sum -= texture2D(CC_Texture0, v_texCoord) * substract.z;
	    sum /= substract.w;
	    gl_FragColor = sum * v_fragmentColor;
	}
	else {
	    gl_FragColor = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
	}
    
//	vec4 sum = vec4(0.0);
//	sum += texture2D(CC_Texture0, v_texCoord - 4.0 * blurSize) * 0.05;
//	sum += texture2D(CC_Texture0, v_texCoord - 3.0 * blurSize) * 0.09;
//	sum += texture2D(CC_Texture0, v_texCoord - 2.0 * blurSize) * 0.12;
//	sum += texture2D(CC_Texture0, v_texCoord - 1.0 * blurSize) * 0.15;
//	sum += texture2D(CC_Texture0, v_texCoord                 ) * 0.16;
//	sum += texture2D(CC_Texture0, v_texCoord + 1.0 * blurSize) * 0.15;
//	sum += texture2D(CC_Texture0, v_texCoord + 2.0 * blurSize) * 0.12;
//	sum += texture2D(CC_Texture0, v_texCoord + 3.0 * blurSize) * 0.09;
//	sum += texture2D(CC_Texture0, v_texCoord + 4.0 * blurSize) * 0.05;
//
//	gl_FragColor = sum;
}

