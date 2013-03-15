//
//  SocketHandler.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "SocketHandler.h"
#import "ProgMeshCentralController.h"
#import "Constants.h"

@implementation SocketHandler{
    
}
@synthesize socket = _socket, host = _host, port = _port, _SOCKET_STATE = _socket_state;

- (id)initWithHostAndPort: (NSString *) host: (NSString *) port
{
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    _socket_state = SOCKET_NOT_CONNECTED_IDLE;

    _host = host;
    _port = port;
    
    return self;
}

- (id)init
{
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    _socket_state = SOCKET_NOT_CONNECTED_IDLE;
    
    //_host = [[NSString alloc] init];
    //_port = [[NSString alloc] init];
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
    [[ProgMeshCentralController sharedInstance] setServerConnectionStatus:NO];
    _socket_state = SOCKET_NOT_CONNECTED_IDLE;
}

- (BOOL) isConnected
{
    if(_socket != nil)
        return [_socket isConnected];
    else
        return NO;
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connected");

    [[ProgMeshCentralController sharedInstance] setServerConnectionStatus:YES];
    _socket_state = SOCKET_CONNECTED_IDLE;
    [[ProgMeshCentralController sharedInstance] didConnectToServer];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    //NSLog(@"dis read %d", data.length);
    [[ProgMeshCentralController sharedInstance] readData:data withTag:tag :_socket_state];
}


-(void) configureHostAndPort:(NSString *)host :(NSString *)port
{
    _host = host;
    _port = port;
}

- (void) socketSendDataWithLengthAndReadTimeOut:(NSData *) data : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout
{
    if (_socket_state == SOCKET_CONNECTED_IDLE) {
        _socket_state = nextState;
        [_socket writeData:data withTimeout:timeout tag:0];
        [_socket readDataWithTimeout:timeout tag:0];
        
        
    }
}

- (void) socketSendDataWithReadTimeOutAndToLength:(NSData *) data : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout : (NSUInteger) length
{
    if (_socket_state == SOCKET_CONNECTED_IDLE) {
        _socket_state = nextState;
        [_socket writeData:data withTimeout:-1 tag:0];
        [_socket readDataToLength:length withTimeout:timeout tag:0];
    }
}

- (void) socketSendMessageWithReadTimeOut:(NSString *) message : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout
{
    if (_socket_state == SOCKET_CONNECTED_IDLE) {
        _socket_state = nextState;
        
        [_socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_socket readDataWithTimeout:timeout tag:0];
    }
}

- (void) socketSendMessageWithReadTimeOutAndToLength:(NSString *) message : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout : (NSUInteger) length
{
    if (_socket_state == SOCKET_CONNECTED_IDLE) {
        _socket_state = nextState;
        [_socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_socket readDataToLength:length withTimeout:timeout tag:0];
    }
}

- (void) socketWaitForMessageWithReadTimeOut: (NSString *) message : (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout
{
    if (_socket_state == SOCKET_CONNECTED_IDLE) {
        _socket_state = nextState;
        [_socket readDataToLength:[message length] withTimeout:timeout tag:0];
    }
}

- (void) socketWaitForDataWithLengthTimeout : (NSInteger) length: (enum SOCKET_STATE) nextState : (NSTimeInterval) timeout
{
    if (_socket_state == SOCKET_CONNECTED_IDLE || _socket_state == SOCKET_WAIT_FOR_SPM_VSPLIT_DATA) {
        _socket_state = nextState;
        [_socket readDataToLength:length withTimeout:timeout tag:0];
    }
}



@end
