//
//  Models.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "Models.h"

@implementation Models

@synthesize VolumeObjects, MeshObjects;

- (void) dealloc
{
    [self.VolumeObjects release];
    [self.MeshObjects release];
    
    [super dealloc];
}


- (NSInteger) volumeCount
{
    return [self.VolumeObjects size];
}

- (NSInteger) meshCount
{
    return [self.MeshObjects size];
}
@end
