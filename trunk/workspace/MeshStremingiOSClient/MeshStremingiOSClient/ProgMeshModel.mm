//
//  ProgMeshModel.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ProgMeshModel.h"

@implementation ProgMeshModel

@synthesize type = _type, name = _name;


- (id) initWithNameAndType:(NSString *) name: (NSString *) type
{
    
    _type = type;
    _name = name;
    BASE_MESH_VERTEX_NORMAL_ARRAY = NULL;
    BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 0;
    
    TOTAL_VERTEX_NORMAL_ARRAY_SIZE = 0;
    
    currentVerticeIdx = 0;
    nCurrentVertices = 0;
    
    MESH_INDICE_ARRAY = NULL;
    MESH_INDICE_ARRAY_SIZE = 0;
    TOTAL_FACE_INDICE_BUFFER_SIZE = 0;
    
    
    currentRecoveredFaceNumber = 0;
    return self;
}

- (void) loadBaseMeshInfo: (NSData *) baseMeshInfoData
{
    
}

- (GLfloat *) getBaseMeshVertexNormalArray
{
    return NULL;
}

- (GLsizei) getBaseMeshVertexNormalArraySize
{
    return 0;
}

- (GLsizei) getTotalVertexNormalArraySize
{
    return 0;
}

- (id) initWithModelObject: (ModelObj *) modelObj
{
    [self init];
    return self;
}

- (float *) getCentroidAndRadius
{
    return centroid_radius;
}

- (int ) getCurrentRecoveredFaceNumber
{
    return currentRecoveredFaceNumber;
}

- (void) setCurrentRecoveredFaceNumber : (int) crfnumber
{
    currentRecoveredFaceNumber = crfnumber;
}


- (int) getCurrentFaceNumberCanDraw
{    
    return currentFaceNumberCanDraw;
}

- (void) setCurrentFaceNumberCanDraw : (int) cfncd
{
    currentFaceNumberCanDraw = cfncd;
}

- (void) setGLObjs : (unsigned int *) vn : (unsigned int *) fi
{
    glvnobj = vn;
    glfiobj = fi;
}

- (float *) get_final_centroid_radius
{
    return final_centroid_radius;
}


@end
