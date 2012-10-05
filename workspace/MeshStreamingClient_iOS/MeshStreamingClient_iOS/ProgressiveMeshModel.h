//
//  ProgressiveMeshModel.h
//  MeshStreamingClient_iOS
//
//  Created by Haiyang Xu on 04.10.12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMStruct.h"



@interface ProgressiveMeshModel : NSObject{
    NSData *baseMeshChunk;
    
    MyMesh *mesh;
    
    //ProgressiveMesh *pm;
    
}




@property NSInteger nBaseVertices;
@property NSInteger nBaseFaces;
@property NSInteger nDetailVertices;
@property NSInteger nMaxVertices;
@property NSInteger sizeBaseMesh;


- (id)init;

//getter
- (NSData*) getBaseMeshChunk;

//setter
- (void) setBaseMeshChunk:(NSData*) data;

@end
