//
//  MeshObjects.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "MeshObjects.h"

@implementation MeshObjects

@synthesize MeshObjs = _meshObjs;

- (void) dealloc
{
    [_meshObjs release];
    
    [super dealloc];
}


- (NSInteger) size
{
    return [_meshObjs count];
}
@end
