//
//  ProgMeshCentralController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketHandler.h"

@interface ProgMeshCentralController : NSObject{
    SocketHandler *_socketHandler;
}


@property (strong, nonatomic) SocketHandler *socketHandler;

@end
