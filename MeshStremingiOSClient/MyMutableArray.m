//
//  MyMutableArray.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 3/9/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "MyMutableArray.h"

@implementation MyMutableArray{
    NSInteger _headPointer;
}

- (id) init
{
    [super init];
    
    _headPointer = 0;
    
    return self;
}

@synthesize headPointer = _headPointer;

@end
