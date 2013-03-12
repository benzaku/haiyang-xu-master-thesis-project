//
//  PMMemoryUpdateInformation.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/26/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "PMMemoryUpdateInformation.h"

#include <set>
//#include <pair.h>
@implementation PMMemoryUpdateInformation{
    std::set<int>   *_vertexNormalUpdatePart;
    std::set<int>   *_indiceUpdatePart;
}

- (id) init{
    self = [super init];
    _vertexNormalUpdatePart = new std::set<int>();
    _indiceUpdatePart = new std::set<int>();
    return self;
}

- (NSArray *) convertSetToNSArray: (std::set<int> *) set
{
    NSArray * array = [[NSArray alloc] init];
}


- (void) clear
{
    _vertexNormalUpdatePart->clear();
    _indiceUpdatePart->clear();
    
    
}

@end
