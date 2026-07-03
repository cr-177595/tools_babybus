// 4个顶点位置位置信息
attribute vec4 a_position;
// 在渲染范围的坐标
attribute vec2 a_texCoord;
// 颜色
attribute vec4 a_color;
// 精度
#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
#endif
// 主函数
void main()
{
    // 给shader内置参数赋值
    gl_Position = CC_PMatrix * a_position;
    // 和片源着色器通信参数
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
}
