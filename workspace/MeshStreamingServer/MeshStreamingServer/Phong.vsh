varying vec3 normal, eyeVec, lightDir;
varying vec4 varycolor;
void main()
{
    gl_Position = ftransform();
    normal = gl_NormalMatrix * gl_Normal;
    vec4 vVertex = gl_ModelViewMatrix * gl_Vertex;
    
    vec4 diffuseColor = vec4(1.0, 0.4, 0.4, 1.0);

    
    eyeVec = -vVertex.xyz;
    lightDir = vec3(0.0, 0.0, 1.0) - vVertex.xyz;
    //vec3(gl_LightSource[0].position.xyz - vVertex.xyz);
    
    float nDotVP = max(0.0, dot(normal, normalize(gl_LightSource[0].position.xyz)));
    
    varycolor = diffuseColor * nDotVP;
}