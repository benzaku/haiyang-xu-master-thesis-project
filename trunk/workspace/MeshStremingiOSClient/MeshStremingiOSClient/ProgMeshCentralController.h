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

#import "ProgMeshGLKViewController.h"

#import "GLRenderViewController.h"

#import "MyMutableArray.h"


@interface ProgMeshCentralController : NSObject{
    SocketHandler *_socketHandler;
    
    ServerInfo *_serverInfo;
    
    ConfigViewController * _configureViewController;
    
    ProgMeshModelTableViewController * _progMeshModelTableViewController;
    
    ProgMeshGLKViewController * _progMeshGLKViewController;
    
    GLRenderViewController * _glRenderViewController;
        
    NSInteger modelListXMLStringLength;
    
    NSString * modelListXMLString;
    
    ModelObj * _currentSelectedModel;
    
    int current_base_mesh_info_data_size;
    
    char * current_base_mesh_info_data;
    
    ProgMeshModel * _progMeshModel;
    
    dispatch_queue_t _refineOperationQueue;
    
    EAGLContext * currentContext;
    
    BOOL duringUpdateing;
    
    bool clientAbort;
    
}

- (NSMutableData *) get_tempData;

- (BOOL) isDuringUpdating;

- (void) setDuringUpdating : (BOOL) updating;

- (id) initWithHostAndPort:(NSString *) host: (NSString *) port;

- (void) configureHostAndPort:(NSString *) host: (NSString * ) port;

+ (id)sharedInstance;

- (SocketHandler *) getSocketHandler;

- (void) setSocketHandler:(SocketHandler *) newSocketHandler;

- (ConfigViewController *) getConfigViewController;

- (void) setConfigViewController: (ConfigViewController *) cvController;

- (ProgMeshModelTableViewController *) getProgMeshModelTableViewController;

- (void) setProgMeshModelTableViewController: (ProgMeshModelTableViewController *) pmmtvController;

- (ProgMeshGLKViewController *) getProgMeshGLKViewController;

- (void) setGLRenderViewController : (GLRenderViewController *) glrvcontroller;

- (GLRenderViewController *) getGLRenderViewController;

- (void) setProgMeshGLKViewController : (ProgMeshGLKViewController *) pmmglkvController;

- (BOOL) isServerConnected;

- (BOOL) setServerConnectionStatus: (BOOL) isConnected;

- (void) readData: (NSData *) data withTag: (long) tag: (enum SOCKET_STATE) waitState;

- (void) didConnectToServer;

- (void) didSelectModelToLoad: (ModelObj *) selectedModel;

- (void) syncViewingParametersToServer : (NSData *) viewing_parameters_;

- (BOOL) getIfNeedUpdateVBO;

- (void) setIfNeedUpdateVBO : (BOOL) value;

- (void) setCurrentContext: (EAGLContext *) context;

- (EAGLContext *) getCurrentContext;

- (void *) get_update_infos;

- (void *) get_update_data;

- (void) setSubUpdateFinish: (BOOL) subupdatefinish;

- (void) setClientAbort : (bool) abort;

- (bool) getClientAbort;

@property (assign, atomic) BOOL subUpdateFinish;

@property (strong, atomic, readwrite) MyMutableArray *updateInfoArray;

@property (atomic, assign) BOOL isQueueBusy;
//@property (strong, atomic) SocketHandler *socketHandler;
@property (strong, atomic) ServerInfo *serverInfo;

@property (strong, atomic) ModelObj * currentSelectedModel;

@property (strong, atomic) ProgMeshModel * progMeshModel;

@end
