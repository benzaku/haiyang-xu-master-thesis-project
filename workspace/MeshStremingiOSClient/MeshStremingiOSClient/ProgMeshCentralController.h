//
//  ProgMeshCentralController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XmlParser.h"

#import "SocketHandler.h"
#import "ServerInfo.h"

#import "GCDSingleton.h"

#import "ConfigViewController.h"

#import "Constants.h"

#import "ProgMeshModelTableViewController.h"

@interface ProgMeshCentralController : NSObject{
    SocketHandler *_socketHandler;
    
    ServerInfo *_serverInfo;
    
    ConfigViewController * _configureViewController;
    
    ProgMeshModelTableViewController * _progMeshModelTableViewController;
    
    NSInteger modelListXMLStringLength;
    
    NSString * modelListXMLString;
    
    ModelObj * _currentSelectedModel;
}

- (id) initWithHostAndPort:(NSString *) host: (NSString *) port;

- (void) configureHostAndPort:(NSString *) host: (NSString * ) port;

+ (id)sharedInstance;

- (SocketHandler *) getSocketHandler;

- (void) setSocketHandler:(SocketHandler *) newSocketHandler;

- (ConfigViewController *) getConfigViewController;

- (void) setConfigViewController: (ConfigViewController *) cvController;

- (ProgMeshModelTableViewController *) getProgMeshModelTableViewController;

- (void) setProgMeshModelTableViewController: (ProgMeshModelTableViewController *) pmmtvController;

- (BOOL) isServerConnected;

- (BOOL) setServerConnectionStatus: (BOOL) isConnected;

- (void) readData: (NSData *) data withTag: (long) tag: (enum SOCKET_STATE) waitState;

- (void) didConnectToServer;

- (void) didSelectModelToLoad: (ModelObj *) selectedModel;

//@property (strong, atomic) SocketHandler *socketHandler;
@property (strong, atomic) ServerInfo *serverInfo;

@property (strong, atomic) ModelObj * currentSelectedModel;
@end
