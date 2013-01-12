//
//  ModelObj.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/4/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ModelObj.h"

@implementation ModelObj
@synthesize ObjectFileName;


- (void) dealloc
{
    [ObjectFileName release];
    ObjectFileName = nil;
    
    [super dealloc];
}
@end
