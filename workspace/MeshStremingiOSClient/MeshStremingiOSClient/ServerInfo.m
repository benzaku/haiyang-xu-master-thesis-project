//
//  ServerInfo.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/16/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ServerInfo.h"

@implementation ServerInfo

@synthesize serverHost = _serverHost, serverPort = _serverPort;

-(id)initWithHostAndPort:(NSString *) host: (NSString *) port
{
    self = [super init];
    _serverHost = host;
    _serverPort = port;
    
    return self;
    
}



@end
