attribute vec4 a_position;
attribute vec4 a_color;
attribute vec2 a_texCoord;

varying   vec2 v_texCoord;
void main(void) {
    gl_Position =  CC_MVMatrix*a_position;
    v_texCoord  = a_texCoord;
}