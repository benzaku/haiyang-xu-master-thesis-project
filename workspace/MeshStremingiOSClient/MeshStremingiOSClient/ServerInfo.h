//
//  ServerInfo.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/16/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerInfo : NSObject{
    NSString *_serverHost;
    NSString *_serverPort;
}

- (void) configureHostAndPort:(NSString *) host: (NSString *) port;

- (id) initWithHostAndPort:(NSString *) host: (NSString *) port;

@property (strong, nonatomic) NSString *serverHost;
@property (strong, nonatomic) NSString *serverPort;

@end
