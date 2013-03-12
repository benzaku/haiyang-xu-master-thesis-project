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
@synthesize Id;
@synthesize ModelType;

- (void) dealloc
{
    [ObjectFileName release];
    ObjectFileName = nil;
    
    [Id release];
    Id = nil;
    
    [ModelType release];
    ModelType = nil;
    
    [super dealloc];
}

- (NSMutableDictionary *) getModelAttributesMap
{
    return nil;
}
@end
