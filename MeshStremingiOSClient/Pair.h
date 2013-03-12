//
//  Pair.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 3/9/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pair : NSObject
{
    void * _first;
    void * _second;
}

- (void) setPair : (void *) a : (void *) b;

- (void *) getFirst;

- (void *) getSecond;
@end