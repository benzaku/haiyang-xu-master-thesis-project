//
//  ProgMeshGLManager.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/15/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ProgMeshModel.h"
#import <QuartzCore/CAEAGLLayer.h>

@interface ProgMeshGLManager : NSObject{
    
    EAGLContext * _context;
    
    GLuint _Program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLKMatrix4 _modelViewMatrix;
        
    ProgMeshModel *progMeshModel;
    
    GLuint _VERTEX_NORMAL_BUFFER_OBJECT;
    GLuint _FACE_INDEX_BUFFER_OBJECT;
    
    GLsizei _positionPointerStride;
    int     _positionPointerOffset;
    
    GLsizei _normalPointerStride;
    int     _normalPointerOffset;
    
    float _centroid[3];
    float _radius;
    
    GLuint defaultFramebuffer, colorRenderbuffer;
    
    // The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
    
    GLuint _backgroundSquareBuffer;
    void *  _updateInfo;
    
@private
    bool    duringVBOUpdate;
    
}

@property (atomic, assign) BOOL duringVBOUpdating;


@property (nonatomic, assign) GLsizei   positionPointerStride;
@property (nonatomic, assign) int       positionPointerOffset;

@property (nonatomic, assign) GLsizei   normalPointerStride;
@property (nonatomic, assign) int       normalPointerOffset;
@property (nonatomic, assign) CAEAGLLayer * layer;

@property (nonatomic, assign) GLuint    program;

@property (nonatomic, assign) GLKMatrix4 modelViewProjectionMatrix;
@property (nonatomic, assign) GLKMatrix3 normalMatrix;

@property (nonatomic, assign) GLKMatrix4 viewingMatrix;

@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;

- (void) setCentroidAndRadius:(float *) centroid_radius;

- (float *) getCentroid;

- (float ) getRadius;


- (void) setProgMeshModel : (ProgMeshModel *) pmModel;

- (ProgMeshModel *) getProgMeshModel;


- (BOOL) loadShaders : (GLuint) _program;

- (EAGLContext *) createEAGLContext;

- (GLKBaseEffect *) createGLKBaseEffect;

- (void) genderateAndBindVertexNormalBufferObject;
- (void) createVertexNormalBufferMemSpace: (GLsizei) totalSize;
- (void) mapBaseMeshVertexNormalBufferData: (GLubyte *) data: (GLsizei) size;

- (void) genderateAndBindFaceIndexBufferObject;
- (void) createFaceIndexBufferMemSpace: (GLsizei) totalSize;
- (void) mapBaseMeshFaceIndexBufferData: (GLubyte *) data: (GLsizei) size;

- (void) enableAttribPointerPositionAndNormal;

- (void) initBaseMeshBuffer: (GLubyte *) vertexNormalData : (GLsizei) vertexNormalDataSize : (GLsizei) vertexNormalDataTotalSize : (GLubyte *) faceIndexData : (GLsizei) faceIndexDataSize : (GLsizei) faceIndexDataTotalSize;

- (void) draw: (GLKBaseEffect *) effect;

- (void) draw2;

- (void) draw3;

- (void) update_vbo: (void *) updateInfo;

- (void) setUpdateInfo:(void *) updateInfo;

- (void *) getUpdateInfo;

- (void *) get_vd_splits;

- (void) try_to_refine;

- (void) try_to_refine: (int) number;


@end
