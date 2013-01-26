//
//  SocketHandler.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"

@interface SocketHandler : NSObject<GCDAsyncSocketDelegate>{
    GCDAsyncSocket *_socket;
}




@property(atomic) enum SOCKET_STATE _SOCKET_STATE;
@property(strong)  GCDAsyncSocket *socket;
@property(atomic, assign) NSString *host;
@property(atomic, assign) NSString *port;

- (id)initWithHostAndPort: (NSString *) host: (NSString *) port;

- (void)configureHostAndPort: (NSString *) _host: (NSString *) _port;

- (void) connectToServer;

- (void) disconnetToServer;

- (BOOL) isConnected;

- (void) socketSendMessageWithReadTimeOut:(NSString *) message : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout;

- (void) socketSendDataWithLengthAndReadTimeOut:(NSData *) data : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout;

- (void) socketSendMessageWithReadTimeOutAndToLength:(NSString *) message : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout : (NSUInteger) length;

- (void) socketWaitForMessageWithReadTimeOut: (NSString *) message : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout;

- (void) socketWaitForDataWithLengthTimeout : (NSInteger) length: (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout;


@end
