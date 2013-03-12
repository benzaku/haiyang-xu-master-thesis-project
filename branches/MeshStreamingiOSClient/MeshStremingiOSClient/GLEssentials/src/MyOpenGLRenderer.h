//
//  MyOpenGLRenderer.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/22/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "OpenGLRenderer.h"
#import <GLKit/GLKit.h>
#import "ProgMeshModel.h"

@interface MyOpenGLRenderer : OpenGLRenderer{
    GLKQuaternion _quaternion;
    float   _scale;
    
    GLuint  _VERTEX_NORMAL_BUFFER_OBJECT;
    GLuint  _FACE_INDEX_BUFFER_OBJECT;
    
    ProgMeshModel * _model;
    
    GLuint  _vertexArray;

}

- (GLuint) buildVBOwithBaseModel: (ProgMeshModel *) model;
- (GLuint) destoryVBO;

- (void) updateQuaternion : (GLKQuaternion) _quat withScale: (float) scale;

@property (nonatomic, assign) bool          isVAOBuilt;
@property (nonatomic, assign) GLKVector3    center;
@property (nonatomic, assign) float         radius;

@end
