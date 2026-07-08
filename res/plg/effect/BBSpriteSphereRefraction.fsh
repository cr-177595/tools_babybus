// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying highp vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform highp vec2 center;
uniform highp float radius;
uniform highp float aspectRatio;
uniform highp float refractiveIndex;

void main()
{
    highp vec2 v_texCoordToUse = vec2(v_texCoord.x, (v_texCoord.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
    highp float distanceFromCenter = distance(center, v_texCoordToUse);
    lowp float checkForPresenceWithinSphere = step(distanceFromCenter, radius);
    
    distanceFromCenter = distanceFromCenter / radius;
    
    highp float normalizedDepth = radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
    highp vec3 sphereNormal = normalize(vec3(v_texCoordToUse - center, normalizedDepth));
    
    highp vec3 refractedVector = refract(vec3(0.0, 0.0, -1.0), sphereNormal, refractiveIndex);
    
    gl_FragColor = texture2D(CC_Texture0, (refractedVector.xy + 1.0) * 0.5) * checkForPresenceWithinSphere;
}

