#ifdef GL_ES 
precision mediump float;
#endif

//用于在顶点着色器和片段着色器之间传递数据
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 targetColor;

#define PI 3.1415926535
uniform float u_time;
uniform float u_ratio;

void main(){
    float maxFactor = 1.0;
    vec2 uv = vec2(0.0);
    // {-1, 1}的取值范围，坐标系原点变成了图片中心
    vec2 xy = 2.0 * v_texCoord.xy - 1.0;
    float d = length(xy);
    if(d < (2.0 - maxFactor)){
        float r = asin(d/1.0)/ PI * 1.0;
        float radian = atan(xy.y, xy.x);
        
        uv.x = r * cos(radian) + 0.5;
        uv.y = r * sin(radian) + 0.5;

        uv.x = fract(uv.x * u_ratio - u_time);
        gl_FragColor = texture2D(CC_Texture0, uv);
        
        // 边缘平滑淡入黑色
        float side = 1.0 - length(vec2(0.5) - v_texCoord) * 2.0;
        gl_FragColor *= smoothstep(0.0, 0.05, side);
    }else{
        gl_FragColor = vec4(0.0);
    }
}