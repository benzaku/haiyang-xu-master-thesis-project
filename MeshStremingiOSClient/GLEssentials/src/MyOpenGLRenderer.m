//
//  MyOpenGLRenderer.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/22/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "MyOpenGLRenderer.h"

#define GetGLError()									\
{														\
GLenum err = glGetError();							\
while (err != GL_NO_ERROR) {						\
NSLog(@"GLError %s set in File:%s Line:%d\n",	\
GetGLErrorString(err),					\
__FILE__,								\
__LINE__);								\
err = glGetError();								\
}													\
}

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


// Uniform index.
#ifndef GL_ENUMS
#define GL_ENUMS
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};
#endif



GLuint m_viewWidth;
GLuint m_viewHeight;
GLuint  _program;

GLKMatrix4 _modelViewProjectionMatrix;
GLKMatrix3 _normalMatrix;
float _rotation;

GLuint _vertexArray;
GLuint _vertexBuffer;

@implementation MyOpenGLRenderer{
    
}

@synthesize center, radius, isVAOBuilt;


- (id) initWithDefaultFBO: (GLuint) defaultFBOName
{
    if((self = [super init]))
    {
        NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
        
        ////////////////////////////////////////////////////
        // Build all of our and setup initial state here  //
        // Don't wait until our real time run loop begins //
        ////////////////////////////////////////////////////
        
        m_defaultFBOName = defaultFBOName;
        isVAOBuilt = false;
        _model = nil;
        [self setup];
    }
    
    return self;
    
}

- (void) setup
{
    center = GLKVector3Make(0, 0, 0);
    
    radius = 1.0f;
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    //glEnable(GL_CULL_FACE);
    
    glClearColor(0.5f, 0.4f, 0.5f, 1.0f);
    
    [self render];
    
    GetGLError();
    
    //glEnable(GL_DEPTH_TEST);
    /*
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
     */
}

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
    glViewport(0, 0, width, height);
    
    m_viewWidth = width;
    m_viewHeight = height;
}
- (void) render
{
    
    
    if(isVAOBuilt){
        float aspect = fabsf((float)m_viewWidth / (float)m_viewHeight);
        GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.0001f, 10000.0f);
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(center.x, center.y, center.z - 3 * radius + _scale * radius);
        
        GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quaternion);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotation);
        
        
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, - center.x, - center.y, - center.z);
        
        GLKMatrix4 transM = GLKMatrix4MakeTranslation(- center.x, - center.y, - center.z);
        
        modelViewMatrix = GLKMatrix4Multiply(transM, modelViewMatrix);
        
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
        
        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        
        glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glBindVertexArray(_vertexArray);
        
        glBindBuffer(GL_ARRAY_BUFFER, _VERTEX_NORMAL_BUFFER_OBJECT);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _FACE_INDEX_BUFFER_OBJECT);
        
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
        glDrawElements(GL_TRIANGLES, [_model getCurrentRecoveredFaceNumber] * 3, GL_UNSIGNED_INT, 0);
        //gldra
        
    }
    else{
        /*
        float aspect = fabsf((float)m_viewWidth / (float)m_viewHeight);
        GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
        
        GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(center.v[0], center.v[0], center.v[0] - 3 * radius + _scale * radius);
        // Compute the model view matrix for the object rendered with ES2
        
        GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quaternion);
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(center.v[0], center.v[0], center.v[0]);
        
        modelViewMatrix= GLKMatrix4Multiply(modelViewMatrix, rotation);
        
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
        
        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
                
        glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glBindVertexArrayOES(_vertexArray);
        
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
        
        glDrawArrays(GL_TRIANGLES, 0, 36);*/
    }
    
}
- (void) dealloc
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if(_program)
    {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    [super dealloc];
    
    
}

- (void) updateQuaternion : (GLKQuaternion) _quat withScale: (float) scale
{
    _quaternion = _quat;
    _scale = scale;
}


- (GLuint) buildVBOwithBaseModel: (ProgMeshModel *) model
{
    
    
    float *center_radius = [model getCentroidAndRadius];
    center.x = center_radius[0];
    center.y = center_radius[1];
    center.z = center_radius[2];
    radius = center_radius[3];
    
    glGenVertexArrays(1, &_vertexArray);
    glBindVertexArray(_vertexArray);
    
    //generate and bind buffer
    glGenBuffers(1, &_VERTEX_NORMAL_BUFFER_OBJECT);
    glBindBuffer(GL_ARRAY_BUFFER, _VERTEX_NORMAL_BUFFER_OBJECT);
    
    //create buffer space
    glBufferData(GL_ARRAY_BUFFER, [model getTotalVertexNormalArraySize], 0, GL_DYNAMIC_DRAW);
    
    //map buffer
    GLvoid * vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    //transfer the vertex data to the vbo
    memcpy(vbo_buffer, [model getBaseMeshVertexNormalArray], [model getBaseMeshVertexNormalArraySize] * sizeof(float));
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    //generate and bind indice buffer
    glGenBuffers(1, &_FACE_INDEX_BUFFER_OBJECT);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _FACE_INDEX_BUFFER_OBJECT);
    
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [model getBaseMeshIndiceBufferSize], 0, GL_STREAM_DRAW);
    
    GLvoid * ibo_buffer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(ibo_buffer, [model getMeshIndiceArray], [model getBaseMeshIndiceBufferSize]);
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    
    _model = model;
    isVAOBuilt = true;
    return _VERTEX_NORMAL_BUFFER_OBJECT;
}
- (GLuint) destoryVBO
{
    
}

- (BOOL) loadShaders
{
    
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
    
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


@end
