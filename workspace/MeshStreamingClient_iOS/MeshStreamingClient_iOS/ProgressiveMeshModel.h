//
//  ProgressiveMeshModel.h
//  MeshStreamingClient_iOS
//
//  Created by Haiyang Xu on 04.10.12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMStruct.h"
#include <set>
#include <pair.h>

typedef std::set<int>          UpdatePartIndex;
typedef std::pair<UpdatePartIndex *, UpdatePartIndex *> UpdateInfo;

@interface ProgressiveMeshModel : NSObject{
    NSData *baseMeshChunk;
    
    MyMesh baseMesh;
    PMInfoContainer details;
    
    GLubyte * baseMeshGLArray;
    GLsizei baseMeshGLArraySize;
    
    GLfloat * BASE_MESH_VERTEX_NORMAL_ARRAY;
    void * currentOffset;
    
    GLsizei BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE;
    GLubyte * BASE_MESH_INDICE_ARRAY;
    GLsizei BASE_MESH_INDICE_ARRAY_SIZE;
    
    unsigned int * MESH_INDICE_ARRAY;
    GLsizei MESH_INDICE_ARRAY_SIZE;
    
    GLubyte * verticeGLArray;
    GLubyte * normalGLArray;
    
    GLsizei currentFaceNumber;
    GLsizei currentVerticeIdx;
    int nCurrentVertices;
    MyMesh::VertexIter currentVertexIter;
    
    GLubyte * VerticeNormalGLArray;
    
    GLsizei TOTAL_VERTEX_NORMAL_ARRAY_SIZE;
    
    GLsizei TOTAL_FACE_INDICE_BUFFER_SIZE;
    
    GLsizei BASE_MESH_INDICE_BUFFER_SIZE;
    
    int currentRecoveredFaceNumber;
    
    UpdatePartIndex updatePartIndex;
    UpdatePartIndex indicePartIndex;
    UpdateInfo updateInfo;
    
    PMInfoIter pmiter;
    int currentPointer;
    //ProgressiveMesh *pm;
    
    MyMesh::Point BBMAX, BBMIN;
    
}




@property NSInteger nBaseVertices;
@property NSInteger nBaseFaces;
@property NSInteger nDetailVertices;
@property NSInteger nMaxVertices;
@property NSInteger sizeBaseMesh;
@property NSInteger nVertices;
@property NSInteger nFaces;
@property MyMesh::Point center;
@property float radius;

- (id)init;

//getter
- (NSData*) getBaseMeshChunk;

//setter
- (void) setBaseMeshChunk:(NSData*) data;



- (GLsizei ) getCurrentFaceNumber;


- (void) addPMDetail:(PMInfo) pminfo;
- (void) addPMDetailsFromNSData:(NSData *) data;

- (PMInfoIter) getPMInfoIter;

- (void) incPMInfoIter;

- (PMInfoIter) getDetailsEnd;

- (size_t) getDetailSize;

- (size_t) getCurrentPointer;

- (void) incCurrentPointer: (int) times;

- (void) clear;

- (GLfloat *) getBaseMeshVertexNormalArray;

- (GLsizei) getBaseMeshVertexNormalArraySize;

- (unsigned int *) getMeshIndiceArray;

- (int) getMeshIndiceArraySize;

- (GLsizei ) getBaseMeshIndiceBufferSize;

- (GLsizei) getTotalVertexNormalArraySize;

- (GLsizei) getTotalFaceIndiceBufferSize;

- (UpdateInfo *) refineWithOffset: (int) steps: (int &) offset: (int &) size;

- (int) getCurrentRecoveredFacesNumber;
@end
