// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform sampler2D CC_Texture1;  //toasterMetal
uniform sampler2D CC_Texture2;  //toasterSoftlight
uniform sampler2D CC_Texture3;  //toasterCurves
uniform sampler2D CC_Texture4;  //toasterOverlayMapWarm
uniform sampler2D CC_Texture5;  //toasterColorshift

void main() {  
    
    lowp vec3 texel;
    mediump vec2 lookup;
    vec2 blue;
    vec2 green;
    vec2 red;
    
    lowp vec4 tmpvar_1;
    tmpvar_1 = texture2D (CC_Texture0, v_texCoord);
    texel = tmpvar_1.xyz;
    
    lowp vec4 tmpvar_2;
    tmpvar_2 = texture2D (CC_Texture1, v_texCoord);
    
    lowp vec2 tmpvar_3;
    tmpvar_3.x = tmpvar_2.x;
    tmpvar_3.y = tmpvar_1.x;
    texel.x = texture2D (CC_Texture2, tmpvar_3).x;

    lowp vec2 tmpvar_4;
    tmpvar_4.x = tmpvar_2.y;
    tmpvar_4.y = tmpvar_1.y;
    texel.y = texture2D (CC_Texture2, tmpvar_4).y;
    
    lowp vec2 tmpvar_5;
    tmpvar_5.x = tmpvar_2.z;
    tmpvar_5.y = tmpvar_1.z;
    texel.z = texture2D (CC_Texture2, tmpvar_5).z;
    red.x = texel.x;
    red.y = 0.16666;
    green.x = texel.y;
    green.y = 0.5;
    blue.x = texel.z;
    blue.y = 0.833333;
    texel.x = texture2D (CC_Texture3, red).x;
    texel.y = texture2D (CC_Texture3, green).y;
    texel.z = texture2D (CC_Texture3, blue).z;
    
    mediump vec2 tmpvar_6;
    tmpvar_6 = ((2.0 * v_texCoord) - 1.0);
    
    mediump vec2 tmpvar_7;
    tmpvar_7.x = dot (tmpvar_6, tmpvar_6);
    tmpvar_7.y = texel.x;
    lookup = tmpvar_7;
    texel.x = texture2D (CC_Texture4, tmpvar_7).x;
    lookup.y = texel.y;
    texel.y = texture2D (CC_Texture4, lookup).y;
    lookup.y = texel.z;
    texel.z = texture2D (CC_Texture4, lookup).z;
    red.x = texel.x;
    green.x = texel.y;
    blue.x = texel.z;
    texel.x = texture2D (CC_Texture5, red).x;
    texel.y = texture2D (CC_Texture5, green).y;
    texel.z = texture2D (CC_Texture5, blue).z;
    
    lowp vec4 tmpvar_8;
    tmpvar_8.w = 1.0;
    tmpvar_8.xyz = texel;
    gl_FragColor = tmpvar_8;
}
