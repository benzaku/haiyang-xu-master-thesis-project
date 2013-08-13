attribute vec4 position;
attribute vec3 normal;

varying lowp vec3 N;
varying lowp vec3 v;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main(void)
{
    
    v = vec3(modelViewProjectionMatrix * position);
    //v = vec3(gl_ModelViewMatrix * gl_Vertex);
    N = normalize(normalMatrix * normal);
    //N = normalize(gl_NormalMatrix * gl_Normal);
    
    
    gl_Position = modelViewProjectionMatrix * position;
    //gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
