//
//  Pair.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 3/9/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "Pair.h"

@implementation Pair{
    
}

- (void) setPair : (void *) a : (void *) b
{
    _first = a;
    _second = b;
}

- (void *) getFirst
{
    return _first;
}

- (void *) getSecond
{
    return _second;
}

- (void) dealloc
{
    free(_first);
    free(_second);
}

@end
