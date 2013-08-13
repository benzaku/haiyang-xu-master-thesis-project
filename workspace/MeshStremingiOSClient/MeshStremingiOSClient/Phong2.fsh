precision mediump float;
varying lowp vec3 N;
varying lowp vec3 v;

void main (void)
{
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 0.4, 0.4, 1.0);
    vec4 specularColor = vec4(1,1,1,1);
    vec3 L = normalize(lightPosition - v);
    //vec3 L = normalize(gl_LightSource[0].position.xyz - v);
    vec3 E = normalize(-v); // we are in Eye Coordinates, so EyePos is (0,0,0)
    vec3 R = normalize(-reflect(L,N));
    
    //calculate Ambient Term:
    vec4 Iamb = vec4(1.0, 0.4, 0.4, 1.0);
    
    //calculate Diffuse Term:
    vec4 Idiff = diffuseColor * max(dot(N,L), 0.0);
    //vec4 Idiff = gl_FrontLightProduct[0].diffuse * max(dot(N,L), 0.0);
    Idiff = clamp(Idiff, 0.0, 1.0);
    
    // calculate Specular Term:
    vec4 Ispec = specularColor * pow(max(dot(R,E),0.0),0.3);
    //vec4 Ispec = gl_FrontLightProduct[0].specular
    //* pow(max(dot(R,E),0.0),0.3*gl_FrontMaterial.shininess);
    Ispec = clamp(Ispec, 0.0, 1.0);
    
    // write Total Color:
    gl_FragColor = Iamb + Idiff + Ispec;
}
