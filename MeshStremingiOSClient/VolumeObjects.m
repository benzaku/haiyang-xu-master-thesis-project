//
//  VolumeObjects.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "VolumeObjects.h"

@implementation VolumeObjects

@synthesize VolumeObjs;

- (void) dealloc
{
    [VolumeObjs release];
    
    [super dealloc];
}

- (NSInteger) size
{
    return [self.VolumeObjs count];
}

@end
