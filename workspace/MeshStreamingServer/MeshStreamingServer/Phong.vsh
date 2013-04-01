varying vec3 normal, eyeVec, lightDir;
void main()
{
    gl_Position = ftransform();
    normal = gl_NormalMatrix * gl_Normal;
    vec4 vVertex = gl_ModelViewMatrix * gl_Vertex;
    eyeVec = -vVertex.xyz;
    lightDir =
    vec3(gl_LightSource[0].position.xyz - vVertex.xyz);
}