//
//  GCDSingleton.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/30/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; 