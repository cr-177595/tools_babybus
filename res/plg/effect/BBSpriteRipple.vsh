attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute float a_edge;


struct RippleData
{
    vec2  center;
    vec2  coor_center;
    int   ripple_type;
    float run_time;
    float current_radius;
};


uniform vec2  texture_max;
uniform int   ripple_num;
uniform RippleData ripples[300];


#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif


void main()
{
    float PI=3.1415927;
    float ripple_cycle = 0.4;
    float ripple_radius = 400.0;
    float life_span = 4.0;
    gl_Position = CC_MVPMatrix * a_position;
    vec2 vertex_pos = a_position.xy;
    if (ripple_num == 0 || a_edge == 1.0)
    {
        v_texCoord = a_texCoord;
    }
    else
    {
        v_texCoord = a_texCoord;
        for (int i = 0; i < ripple_num; i++)
        {
            float ripple_distance = distance(ripples[i].center, vertex_pos);
            float correction = 0.0;
            if (ripple_distance < ripples[i].current_radius)
            {
                if (ripples[i].ripple_type == 0)
                {
                   correction = sin(2.0 * PI * ripples[i].run_time / ripple_cycle);
                }
                else if (ripples[i].ripple_type == 1)
                {
                   correction = sin(2.0 * PI * (ripples[i].current_radius - ripple_distance)/ ripple_radius * life_span / ripple_cycle);
                }
                else
                {
                   correction = (ripple_radius * ripple_cycle / life_span)/(ripples[i].current_radius - ripple_distance);
                   if (correction > 1.0) correction = 1.0;
                   correction = correction * correction;
                   correction = sin(2.0 * PI * (ripples[i].current_radius - ripple_distance) / ripple_radius * life_span / ripple_cycle) * correction;


                }
                correction = correction * (1.0 - ripple_distance / ripples[i].current_radius);
                correction = correction * (1.0 - ripples[i].run_time / life_span);
                correction = correction * 0.1;
                correction = correction * 2.0;            
                correction = correction / distance(ripples[i].coor_center, v_texCoord);
                v_texCoord = v_texCoord + (v_texCoord - ripples[i].coor_center) * correction;
                v_texCoord = clamp(v_texCoord, vec2(0.0, 0.0), texture_max); 
            }
        }
    }
}

