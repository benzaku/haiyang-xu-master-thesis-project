//
//  ProgMeshModel.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObj.h"



@interface ProgMeshModel : NSObject{
    NSString * _type;
    NSString * _name;
    
    GLfloat * BASE_MESH_VERTEX_NORMAL_ARRAY;
    GLsizei BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE;                //length of whole data chunk
    
    GLsizei TOTAL_VERTEX_NORMAL_ARRAY_SIZE;
    
    GLsizei currentVerticeIdx;
    int nCurrentVertices;
    
    unsigned int * MESH_INDICE_ARRAY;
    GLsizei BASE_MESH_INDICE_BUFFER_SIZE;
    GLsizei MESH_INDICE_ARRAY_SIZE;
    GLsizei TOTAL_FACE_INDICE_BUFFER_SIZE;

    float centroid_radius[4];
    
    float final_centroid_radius[4];
    
    int currentRecoveredFaceNumber;
    
    int currentFaceNumberCanDraw;
    
    unsigned int *glvnobj;
    
    unsigned int *glfiobj;

}

- (void) setGLObjs : (unsigned int *) vn : (unsigned int *) fi;

- (id) initWithNameAndType:(NSString *) name: (NSString *) type;

- (id) initWithModelObject: (ModelObj *) modelObj;

- (void) loadBaseMeshInfo: (NSData *) baseMeshInfoData;

- (GLfloat *) getBaseMeshVertexNormalArray;

- (GLsizei) getBaseMeshVertexNormalArraySize;

- (GLsizei) getTotalVertexNormalArraySize;

- (GLsizei) getTotalFaceIndiceBufferSize;

- (GLsizei) getBaseMeshIndiceBufferSize;


- (unsigned int *) getMeshIndiceArray;

- (float *) getCentroidAndRadius;

- (int ) getCurrentRecoveredFaceNumber;

- (void) setCurrentRecoveredFaceNumber: (int) crfnumber;

- (int) getCurrentFaceNumberCanDraw;

- (void) setCurrentFaceNumberCanDraw : (int) cfncd;

- (float *) get_final_centroid_radius;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;

@end
