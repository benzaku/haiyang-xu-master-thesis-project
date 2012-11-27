//
//  ProgMeshCentralController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketHandler.h"
#import "ServerInfo.h"

@interface ProgMeshCentralController : NSObject{
    SocketHandler *_socketHandler;
    
    ServerInfo *_serverInfo;
}


@property (strong, nonatomic) SocketHandler *socketHandler;
@property (strong, nonatomic) ServerInfo *serverInfo;


@end
