//
//  ProgressiveMeshModel.m
//  MeshStreamingClient_iOS
//
//  Created by Haiyang Xu on 04.10.12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#import "ProgressiveMeshModel.h"

@implementation ProgressiveMeshModel

@synthesize nMaxVertices;
@synthesize nBaseVertices;
@synthesize nBaseFaces;
@synthesize nDetailVertices;
@synthesize sizeBaseMesh;

- (id)init
{
    NSLog(@"ProgressiveMeshModel Init...");
    if(self=[super init]){ 
        nBaseVertices = 0;
        nBaseFaces = 0;
        nMaxVertices = 0;
        nDetailVertices = 0;
    }
    //MyMesh mesh;
    return self;
}

- (NSData *)getBaseMeshChunk
{
    return baseMeshChunk;
}

- (void)setBaseMeshChunk:(NSData *)data
{
    baseMeshChunk = [[NSData alloc] initWithData:data];
}

@end
