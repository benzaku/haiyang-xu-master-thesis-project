//
//  MeshObj.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "MeshObj.h"

@implementation MeshObj

@synthesize ObjectFilePath;
@synthesize RootDirPath;
@synthesize ObjectFileName;

- (void) dealloc
{
    [ObjectFilePath release];
    ObjectFilePath = nil;
    
    [RootDirPath release];
    RootDirPath = nil;
    
    [ObjectFileName release];
    ObjectFileName = nil;
    
    [super dealloc];
}

@end
