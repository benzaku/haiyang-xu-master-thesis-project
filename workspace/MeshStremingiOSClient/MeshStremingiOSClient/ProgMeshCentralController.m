//
//  ProgMeshCentralController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ProgMeshCentralController.h"

@implementation ProgMeshCentralController


- (id)init
{
    _socketHandler = [[[SocketHandler alloc] init] autorelease];
    
    _serverInfo = [[[ServerInfo alloc] init] autorelease];
    
    return self;
}

@synthesize socketHandler = _socketHandler, serverInfo = _serverInfo;
@end
