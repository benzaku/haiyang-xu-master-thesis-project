//
//  ProgMeshCentralController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ProgMeshCentralController.h"

#import "Constants.h"

#import "Models.h"

#import "VolumeObj.h"

#import "MeshObj.h"

@implementation ProgMeshCentralController

static id SharedInstance;

- (id)init
{
    _socketHandler = [[[SocketHandler alloc] init] autorelease];
    
    _serverInfo = [[[ServerInfo alloc] init] autorelease];
    
    _currentSelectedModel = nil;
    
    return self;
}

- (id) initWithHostAndPort:(NSString *) host: (NSString *) port
{
    //[super init];
    _socketHandler = [[[SocketHandler alloc] initWithHostAndPort:host :port] autorelease];
    _serverInfo = [[[ServerInfo alloc] initWithHostAndPort:host :port] autorelease];
    return self;
}

- (void) configureHostAndPort:(NSString *)host :(NSString *)port
{
    if(_socketHandler != nil){
        
        
        //[_socketHandler release];
        [_socketHandler setHost:host];
       
    }
    
    
}

+ (id)sharedInstance
{
    if (SharedInstance == nil) {
        
        DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
            SharedInstance = [[self alloc] init];
            return SharedInstance;
        });
    }
    
    return SharedInstance;
}


- (SocketHandler *) getSocketHandler
{
    return _socketHandler;
}

- (void) setSocketHandler:(SocketHandler *) newSocketHandler
{
    _socketHandler = newSocketHandler;
}


- (ConfigViewController *) getConfigViewController
{
    return _configureViewController;
}

- (void) setConfigViewController: (ConfigViewController *) cvController
{
    _configureViewController = cvController;
}

- (ProgMeshModelTableViewController *) getProgMeshModelTableViewController
{
    return _progMeshModelTableViewController;
}

- (void) setProgMeshModelTableViewController: (ProgMeshModelTableViewController *) pmmtvController
{
    _progMeshModelTableViewController = pmmtvController;
}

- (BOOL) isServerConnected
{
    if(_socketHandler != nil){
        return [_socketHandler isConnected];
    }
    else
        return NO;
}

- (BOOL) setServerConnectionStatus: (BOOL) isConnected
{
    if (isConnected) {
        //connected
        _configureViewController.statusBar.backgroundColor = [UIColor greenColor];
        _configureViewController.statusBar.text = SERVER_STATE_CONNECTED;
        [_configureViewController.connectButton setTitle:BUTTON_TEXT_DISCONNECT forState:UIControlStateNormal];
        
        
    }
    else{
        _configureViewController.statusBar.backgroundColor = [UIColor redColor];
        _configureViewController.statusBar.text = SERVER_STATE_NOT_CONNECTED;
        [_configureViewController.connectButton setTitle:BUTTON_TEXT_CONNECT forState:UIControlStateNormal];
        
        [_progMeshModelTableViewController resetTable];
    }
    
    return NO;
}
- (void) readData: (NSData *) data withTag: (long) tag : (enum SOCKET_STATE) waitState
{
    
    _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;

    switch (waitState) {
        case SOCKET_WAIT_FOR_HELLO:
            [self handleWaitForHelloFromServer:data];
            break;
            
        case SOCKET_WAIT_FOR_MODEL_LIST_SIZE:
            
            
            [self handleWaitForModelListSize:data];
            break;
            
        case SOCKET_WAIT_FOR_MODEL_LIST:
            [self handleWaitForModelList:data];
            
            break;
            
        case SOCKET_WAIT_SERVER_LOAD_MODEL:
            [self handleWaitForServerLoadModel:data];
            break;
        default:
            break;
    }
    
}

- (void) handleWaitForServerLoadModel : (NSData *) data
{
    NSLog(@"get from server ... %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void) handleWaitForHelloFromServer : (NSData *) data
{
    NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([HELLO_FROM_SERVER compare: temp]== NSOrderedSame){
        NSLog(@"Received Server says HELLO");
        [_socketHandler socketSendMessageWithReadTimeOut:COMMAND_REQUEST_MODEL_LIST_XML_SIZE :SOCKET_WAIT_FOR_MODEL_LIST_SIZE :-1];
    } else{
        NSLog(@"ERROR, Server returns illegal message : %@", temp);
    }
}


- (void) handleWaitForModelListSize: (NSData *) data
{
    int receivedInt = 0;
    [data getBytes:&receivedInt length:sizeof(int)];
    modelListXMLStringLength = receivedInt;
    
    NSLog(@"length of ModelListXML = %d\n",receivedInt);
    
    [_socketHandler socketSendMessageWithReadTimeOutAndToLength:COMMAND_REQUEST_MODEL_LIST_XML :SOCKET_WAIT_FOR_MODEL_LIST :-1 :receivedInt];
}

- (void) handleWaitForModelList: (NSData *) data
{
    modelListXMLString = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"get Data:\n%@", modelListXMLString);
    
    [self createXMLDocumentObjectFromString:data];

}

- (void) createXMLDocumentObjectFromString: (NSData *) xmlData
{
    XmlParser *parser = [[[XmlParser alloc] init] autorelease];
   
    Models *models = [[[Models alloc] init] autorelease];
    
    NSMutableArray *modelArray = [parser fromXml:modelListXMLString withObject:models];
    
    NSLog(@"models :: %@", modelArray);
    
    MeshObj *meshObj = [[[MeshObj alloc] init] autorelease];
    
    VolumeObj *volObj = [[[VolumeObj alloc] init] autorelease];
    
    _progMeshModelTableViewController.meshes = [parser fromXml:modelListXMLString withObject:meshObj];
    
    _progMeshModelTableViewController.volumes = [parser fromXml:modelListXMLString withObject:volObj];
    
    [_progMeshModelTableViewController.tableView reloadData];
}

- (void) didConnectToServer
{
    //retrieve mesh list
    NSLog(@"Start to retrieve model list size");
    
    [_socketHandler socketWaitForMessageWithReadTimeOut:HELLO_FROM_SERVER :SOCKET_WAIT_FOR_HELLO :-1];
    
}

- (void) didSelectModelToLoad: (ModelObj *) selectedModel
{
    _currentSelectedModel = selectedModel;
    
    [self requestServerLoadModel:[_currentSelectedModel.Id intValue]];
    
}

- (void) requestServerLoadModel: (int) modelId
{
    int request_length = [COMMAND_REQUEST_LOAD_MODEL length] + sizeof(int);
    char request[request_length];
    strcpy(request, [COMMAND_REQUEST_LOAD_MODEL cStringUsingEncoding:NSUTF8StringEncoding]);
    strncpy(&(request[[COMMAND_REQUEST_LOAD_MODEL length]]), (char *)&modelId, sizeof(int));
    NSLog(@"id = %d", modelId);
    [_socketHandler socketSendDataWithLengthAndReadTimeOut:[[NSData alloc] initWithBytes:request length:(request_length)] :SOCKET_WAIT_SERVER_LOAD_MODEL :-1];
}


@synthesize  serverInfo = _serverInfo;
@synthesize  currentSelectedModel = _currentSelectedModel;
@end
