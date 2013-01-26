//
//  ProgMeshGLManager.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/15/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "ProgMeshGLManager.h"

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

GLfloat backgroundSquare[] =
{
    3.f, 4.f, -8.f,    0.0f, 0.0f, 1.0f,
    -3.f, 4.f, -8.0f,    0.0f, 0.0f, 1.0f,
    3.f, -4.f, -8.0f,   0.0f, 0.0f, 1.0f,
    -3.f, -4.f, -8.0f,   0.0f, 0.0f, 1.0f
};


@implementation ProgMeshGLManager

- (void) setProgMeshModel : (ProgMeshModel *) pmModel
{
    progMeshModel = pmModel;
}

- (ProgMeshModel *) getProgMeshModel
{
    return progMeshModel;
}

- (GLKBaseEffect *) createGLKBaseEffect
{
    return  [[GLKBaseEffect alloc] init];

}

- (EAGLContext *) createEAGLContext
{
    
     _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    return _context;
}

- (void) initBaseMeshBuffer: (GLubyte *) vertexNormalData : (GLsizei) vertexNormalDataSize : (GLsizei) vertexNormalDataTotalSize : (GLubyte *) faceIndexData : (GLsizei) faceIndexDataSize : (GLsizei) faceIndexDataTotalSize
{
    [self genderateAndBindVertexNormalBufferObject];
    [self createVertexNormalBufferMemSpace:vertexNormalDataTotalSize];
    [self mapBaseMeshVertexNormalBufferData:vertexNormalData :vertexNormalDataSize];
    
    [self enableAttribPointerForPositionAndNormal];
    
    [self genderateAndBindFaceIndexBufferObject];
    [self createFaceIndexBufferMemSpace:faceIndexDataTotalSize];
    [self mapBaseMeshFaceIndexBufferData:faceIndexData :faceIndexDataSize];
}


- (void) genderateAndBindVertexNormalBufferObject
{
    glGenBuffers(1, &_VERTEX_NORMAL_BUFFER_OBJECT);
    glBindBuffer(GL_ARRAY_BUFFER, _VERTEX_NORMAL_BUFFER_OBJECT);
}

- (void) createVertexNormalBufferMemSpace: (GLsizei) totalSize
{
    glBufferData(GL_ARRAY_BUFFER, totalSize, 0, GL_DYNAMIC_DRAW);

}

- (void) mapBaseMeshVertexNormalBufferData: (GLubyte *) data: (GLsizei) size
{
    GLvoid * vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    //transfer the vertex data to the vbo
    memcpy(vbo_buffer, data, size);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}


- (void) genderateAndBindFaceIndexBufferObject
{
    glGenBuffers(1, &_FACE_INDEX_BUFFER_OBJECT);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _FACE_INDEX_BUFFER_OBJECT);
    
}

- (void) mapBaseMeshFaceIndexBufferData: (GLubyte *) data: (GLsizei) size
{
    GLvoid * ibo_buffer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(ibo_buffer, data, size);
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);

}

- (void) createFaceIndexBufferMemSpace: (GLsizei) totalSize
{
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, totalSize, 0, GL_STREAM_DRAW);

}

- (void) enableAttribPointerForPositionAndNormal
{
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, _positionPointerStride, BUFFER_OFFSET(_positionPointerOffset));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, _normalPointerStride, BUFFER_OFFSET(_normalPointerOffset));
}




- (BOOL) loadShaders : (GLuint) _program
{
        
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    _Program = _program;

    
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

- (void) setCentroidAndRadius:(float *) centroid_radius
{
    _centroid[0] = centroid_radius[0];
    _centroid[1] = centroid_radius[1];
    _centroid[2] = centroid_radius[2];
    
    _radius = centroid_radius[3];
}

- (float *) getCentroid
{
    return _centroid;
}

- (float) getRadius
{
    return _radius;
}

- (void) draw: (GLKBaseEffect *) effect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VERTEX_NORMAL_BUFFER_OBJECT);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _FACE_INDEX_BUFFER_OBJECT);
    
    // Render the object with GLKit
    [effect prepareToDraw];
    
    
    int facenumber1 = [progMeshModel getCurrentRecoveredFaceNumber] / 2;
    int facenumber2 = [progMeshModel getCurrentRecoveredFaceNumber] - facenumber1;
    int offset = facenumber1 * 3 * sizeof(unsigned int);
    
    //glDrawElements(GL_TRIANGLES, [progMeshModel getCurrentRecoveredFaceNumber] * 3 , GL_UNSIGNED_INT, 0);
    glDrawElements(GL_TRIANGLES, facenumber1 * 3, GL_UNSIGNED_INT, 0);
    glDrawElements(GL_TRIANGLES, facenumber2 * 3, GL_UNSIGNED_INT, BUFFER_OFFSET(offset));

    
}

- (void) draw2
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VERTEX_NORMAL_BUFFER_OBJECT);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _FACE_INDEX_BUFFER_OBJECT);
    
    // Render the object with GLKit
    //[effect prepareToDraw];
    glUseProgram(_Program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    int facenumber = [progMeshModel getCurrentRecoveredFaceNumber];
    
    glDrawElements(GL_TRIANGLES, facenumber * 3, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    
    
}

- (void) update_vbo
{
    
}


@synthesize positionPointerStride = _positionPointerStride;
@synthesize positionPointerOffset = _positionPointerOffset;
@synthesize normalPointerStride = _normalPointerStride;
@synthesize normalPointerOffset = _normalPointerOffset;
@synthesize program = _Program;
@synthesize modelViewProjectionMatrix = _modelViewProjectionMatrix;
@synthesize normalMatrix = _normalMatrix;

@synthesize layer;

@end