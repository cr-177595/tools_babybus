#ifdef GL_ES
precision mediump float;      // 设置浮点数精度（中等精度）
#endif

// 传入的参数
varying vec2 v_texCoord;      // 顶点着色器传入的纹理坐标
uniform vec2 centerP;         // 波纹的中心点坐标
uniform float time;           // 波纹的运行时间
uniform float strength;       // 波纹强度

// 噪声函数
float noise(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(1000.0, 1000.0))));
}

void main()
{
    vec2 uv = v_texCoord.xy;              // 在纹理上的坐标
    float dist = distance(uv, centerP);   // 计算当前点到中心点的距离
    float speed = 10.0;                   // 波纹速度
    float freq = 60.0;                    // 波纹频率，影响波纹的密集程度
    float amplitude = 0.005 * strength;   // 波纹振幅
    float radius = 0.2;                   // 波纹最大半径
    float limitArea = step(dist, radius); // 波纹区域限制

    // 正弦波纹
    float wave = amplitude * sin(dist * freq - time * speed);
    // 叠加波纹后改变的纹理坐标
    vec2 waveUV = uv + wave * normalize(uv - centerP) * limitArea;
    // 叠加波纹后混合的纹理颜色
    vec4 waveColor = texture2D(CC_Texture0, waveUV);

    // 光晕的透明度
    float lightOpa = 0.2;
    // 光晕的宽度，离中心点越近宽度越大，离中心点越远宽度越小。
    float lightW = mix(0.02, 0.2, pow(dist / radius, 2.0));
    // 光晕的强度，离心点越远强度越强，离心点越远强度越弱。
    float lightStrength = mix(1.0, 0.0, sqrt(dist / radius));
    // 光晕相位，可以随时间变化而呈现波动的效果。
    float lightPhase = dist * freq - time * speed * 0.5;
    // 光晕边缘产生更柔和的过渡，使得光晕边缘不会太过尖锐。
    float light = lightStrength * smoothstep(lightW, 0.0, pow(sin(lightPhase), 2.0));
    // 添加噪声让光晕产生融解效果
    light = light * noise(uv); 
    // 光晕颜色（这里如果用1.0会导致光晕呈黑色，所以用10.0）
    vec4 lightColor = vec4(10.0, 10.0, 10.0, light * lightOpa * strength) * limitArea;

    gl_FragColor = mix(waveColor, lightColor, lightColor.a);
}