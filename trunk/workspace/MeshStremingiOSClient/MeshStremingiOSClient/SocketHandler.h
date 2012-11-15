//
//  SocketHandler.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketHandler : NSObject<GCDAsyncSocketDelegate>{
    GCDAsyncSocket *_socket;
}


@property(strong)  GCDAsyncSocket *socket;
@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) NSString *port;

- (id)initWithHostAndPort: (NSString *) _host: (NSString *) _port;

- (void) connectToServer;

- (void) disconnetToServer;

- (BOOL) isConnected;

@end
