//
//  ProgMeshModels.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ProgMeshModelArray.h"
#import "ProgMeshModel.h"

@implementation ProgMeshModelArray


-(id)initWithArray:(NSArray *)array
{
    self = [super initWithArray:array];
    ProgMeshModel *first = [self objectAtIndex:0];
    _type = first.type;

    
    
}

@synthesize type = _type;




@end
