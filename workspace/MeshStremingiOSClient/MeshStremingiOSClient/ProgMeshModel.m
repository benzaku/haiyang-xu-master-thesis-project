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
    return self;
}

@end
