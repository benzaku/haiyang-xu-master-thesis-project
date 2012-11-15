//
//  SocketHandler.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "SocketHandler.h"

@implementation SocketHandler{
    
}
@synthesize socket = _socket, host = _host, port = _port;

- (id)initWithHostAndPort: (NSString *) host: (NSString *) port
{
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    _host = host;
    _port = port;
    
    return self;
}

- (id)init
{
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    return self;
}

- (void) connectToServer
{
    NSError *err = nil;
    if(![_socket connectToHost:_host onPort:[_port intValue] error:&err])
    {
        NSLog(@"%@", err.description);
        
    }else
    {
        NSLog(@"ok");
        NSLog(@"socket connected!");
    }

}

- (void) disconnetToServer
{
    [_socket disconnect];
}

- (BOOL) isConnected
{
    return [_socket isConnected];
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connected");
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"get Data");
}

@end
