varying vec3 normal, eyeVec, lightDir;
varying vec4 varycolor;


void main (void)
{
    /*
    vec4 final_color =
    gl_FrontLightModelProduct.sceneColor;
    vec3 N = normalize(normal);
    vec3 L = normalize(lightDir[0]);
    float lambertTerm = dot(N,L);
    if (lambertTerm > 0.0)
    {
        final_color +=
        gl_LightSource[0].diffuse *
        gl_FrontMaterial.diffuse *
        lambertTerm;
        vec3 E = normalize(eyeVec);
        vec3 R = reflect(-L, N);
        float specular = pow(max(dot(R, E), 0.0),
        gl_FrontMaterial.shininess);
        final_color +=
        gl_LightSource[0].specular *
        gl_FrontMaterial.specular *
        specular;
    }
     */
    //gl_FragColor = final_color;
    gl_FragColor = varycolor;
    //vec4(1.0, 0.4, 0.4, 1.0)
}