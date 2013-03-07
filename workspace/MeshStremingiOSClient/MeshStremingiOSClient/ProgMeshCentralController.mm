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

#import "VDPMModel.h"

@implementation ProgMeshCentralController{
    
}

static id SharedInstance;

- (id)init
{
    _socketHandler = [[[SocketHandler alloc] init] autorelease];
    
    _serverInfo = [[[ServerInfo alloc] init] autorelease];
    
    _currentSelectedModel = nil;
    
    _progMeshModel = nil;
    
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

- (ProgMeshGLKViewController *) getProgMeshGLKViewController
{
    return _progMeshGLKViewController;
}

- (void) setProgMeshGLKViewController : (ProgMeshGLKViewController *) pmmglkvController
{
    _progMeshGLKViewController = pmmglkvController;
}

- (void) setGLRenderViewController : (GLRenderViewController *) glrvcontroller
{
    _glRenderViewController = glrvcontroller;
}

- (GLRenderViewController *) getGLRenderViewController
{
    return _glRenderViewController;
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
    
    
    
    switch (waitState) {
        case SOCKET_WAIT_FOR_SPM_VSPLIT_DATA:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            
            [self handleWaitForSPMVsplitData:data];
            break;
            
        case SOCKET_WAIT_FOR_SPM_VSPLIT_DATA_SIZE:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            [self handleWaitForSPMVsplitDataSize:data];
            
            break;
            
        case SOCKET_WAIT_FOR_SPM_BASE_INFO_DATA:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            [self handleWaitForSPMBaseInfoData:data];
            break;
            
        case SOCKET_WAIT_FOR_SPM_BASE_INFO_DATA_SIZE:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            [self handleWaitForSPMBaseInfoDataSize: data];
            break;
        case SOCKET_WAIT_FOR_HELLO:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            [self handleWaitForHelloFromServer:data];
            break;
            
        case SOCKET_WAIT_FOR_MODEL_LIST_SIZE:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            
            [self handleWaitForModelListSize:data];
            break;
            
        case SOCKET_WAIT_FOR_MODEL_LIST:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            [self handleWaitForModelList:data];
            
            break;
            
        case SOCKET_WAIT_SERVER_LOAD_MODEL:
            _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;
            [self handleWaitForServerLoadModel:data];
            break;
        default:
            break;
    }
    
}

int n_vsplit_packet_remain;
int total_vsplit;

int n_vsplit_remaining;
int n_vsplit_in_this_packet;

int bytes_to_come;

int total_size;

int offset;

#define VSPLIT_EACH_PACKET  100
#define SIZE_OF_A_VSPLIT    80
#define BYTE_PER_READ       8000

int current_idx;

- (void) handleWaitForSPMVsplitData: (NSData *) data
{
    int data_length = data.length;
    
    
    //((std::vector<NSData *> *)[[_progMeshGLKViewController getProgMeshGLManager] get_vd_splits])->push_back([[NSData alloc] initWithData:data]);
    //request for next packet;
    
    
    int req_num = current_idx + VSPLIT_EACH_PACKET > total_vsplit ? total_vsplit - current_idx : VSPLIT_EACH_PACKET;
    int idx_num[2];
    
    if(req_num > 0){
        idx_num[0] = current_idx;
        idx_num[1] = req_num;
     
        int sendDataLength = COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM.length + 2 * sizeof(int);
        char sendData[sendDataLength];
        
        memcpy(sendData, [COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM cStringUsingEncoding:NSUTF8StringEncoding], COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM.length);
        memcpy((char *)&(sendData[COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM.length]), idx_num, 2*sizeof(int));
        
        
        int readLength = idx_num[1] * SIZE_OF_A_VSPLIT;
        [_socketHandler socketSendDataWithReadTimeOutAndToLength:[[NSData alloc] initWithBytes:sendData length:sendDataLength] :SOCKET_WAIT_FOR_SPM_VSPLIT_DATA :-1 :readLength];        
    }
    else{
        _socketHandler._SOCKET_STATE = SOCKET_CONNECTED_IDLE;        
    }
    [_progMeshGLKViewController.progress setProgress:(float) (current_idx) / (float)total_vsplit];
    current_idx += idx_num[1];
}

- (void) handleWaitForSPMVsplitDataSize: (NSData *) data
{
    char header_size[8 + sizeof(int)];
    [data getBytes:header_size length:8 + sizeof(int)];
    
    //[data getBytes:&size];
    char h[8];
    strncpy(h, header_size, 8);
    int size;
    memcpy(&size, &header_size[8], sizeof(int));
    
    //NSLog(@"header = %s, size = %d", h, size);
    
    [_progMeshGLKViewController.progress setProgress:0.0f];
    
    total_vsplit = size / SIZE_OF_A_VSPLIT;
    n_vsplit_remaining = total_vsplit;
    total_size = size;
    bytes_to_come = size;
    current_idx = 0;
    
    int initial_vsplit_pack_count = total_vsplit > VSPLIT_EACH_PACKET? VSPLIT_EACH_PACKET : total_vsplit;
    int idx_size[2];
    idx_size[0] = current_idx;
    idx_size[1] = initial_vsplit_pack_count;
    if(initial_vsplit_pack_count > 0){
        int sendDataLength = COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM.length + 2 * sizeof(int);
        char sendData[sendDataLength];
        
        memcpy(sendData, [COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM cStringUsingEncoding:NSUTF8StringEncoding], COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM.length);
        memcpy((char *)&(sendData[COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM.length]), idx_size, 2*sizeof(int));
        int readLength = initial_vsplit_pack_count * SIZE_OF_A_VSPLIT;
        
        [_socketHandler socketSendDataWithReadTimeOutAndToLength:[[NSData alloc] initWithBytes:sendData length:sendDataLength] :SOCKET_WAIT_FOR_SPM_VSPLIT_DATA :-1 :readLength];
    }
    current_idx += initial_vsplit_pack_count;
    /*
    if(size > 0){
        if(size > BYTE_PER_READ){
            [_socketHandler socketSendMessageWithReadTimeOutAndToLength:COMMAND_RETIEVE_SPM_VSPLIT_DATA :SOCKET_WAIT_FOR_SPM_VSPLIT_DATA :-1 :BYTE_PER_READ];
        }
        else{
            [_socketHandler socketSendMessageWithReadTimeOutAndToLength:COMMAND_RETIEVE_SPM_VSPLIT_DATA :SOCKET_WAIT_FOR_SPM_VSPLIT_DATA :-1 :size];
        }
    }
     */
    
}

- (void) handleWaitForSPMBaseInfoData: (NSData *) data
{
    NSLog(@"handleWaitForSPMBaseInfoData : get data" );
    
    if (_progMeshModel != nil) {
        [_progMeshModel release];
    }
    if ([_currentSelectedModel.ModelType compare:@"SPM"] == NSOrderedSame){
        _progMeshModel = [[VDPMModel alloc] initWithModelObject:_currentSelectedModel];
        [_progMeshModel loadBaseMeshInfo:data];
        
#ifdef USE_FBO
        
        [_glRenderViewController setProgMeshModel:_progMeshModel];
        [[_glRenderViewController.glView getRenderer] buildVBOwithBaseModel:_progMeshModel];
#else
        [[_progMeshGLKViewController getProgMeshGLManager] setProgMeshModel:_progMeshModel];
        
        [_progMeshGLKViewController setProgMeshModel:_progMeshModel];
        
        [_progMeshGLKViewController setScenePosition:[_progMeshModel getCentroidAndRadius]];
        
        [[_progMeshGLKViewController getProgMeshGLManager] setCentroidAndRadius:[_progMeshModel getCentroidAndRadius]];
        
        [[_progMeshGLKViewController getProgMeshGLManager] setPositionPointerStride:24];
        [[_progMeshGLKViewController getProgMeshGLManager] setPositionPointerOffset:0];
        [[_progMeshGLKViewController getProgMeshGLManager] setNormalPointerStride:24];
        [[_progMeshGLKViewController getProgMeshGLManager] setNormalPointerOffset:12];
        
        [[_progMeshGLKViewController getProgMeshGLManager] initBaseMeshBuffer:(GLubyte *)[_progMeshModel getBaseMeshVertexNormalArray] :[_progMeshModel getBaseMeshVertexNormalArraySize] * sizeof(float) :[_progMeshModel getTotalVertexNormalArraySize] * sizeof(float) :(GLubyte *)[_progMeshModel getMeshIndiceArray] :[_progMeshModel getBaseMeshIndiceBufferSize] :[_progMeshModel getTotalFaceIndiceBufferSize]];
        
        _progMeshGLKViewController.status = PM_VIEW_STATUS_SPM_RENDER_BASE_MESH;
        
        //request for details
        //[self requestForVDPMDetails];
#endif
        
    }
    
    
}

- (void) requestForVDPMDetails
{
    [_socketHandler socketSendMessageWithReadTimeOut:COMMAND_RETIEVE_SPM_DETAILS :SOCKET_WAIT_FOR_SPM_DETAILS_DATA :-1];
}

- (void) handleWaitForSPMBaseInfoDataSize : (NSData *) data
{
    [data getBytes:&current_base_mesh_info_data_size length:sizeof(int)];
    NSLog(@"size = %d", current_base_mesh_info_data_size );
    
    [_socketHandler socketSendMessageWithReadTimeOutAndToLength:COMMAND_REQUEST_SPM_BASE_INFO_DATA :SOCKET_WAIT_FOR_SPM_BASE_INFO_DATA :-1 :current_base_mesh_info_data_size];
}

- (void) handleWaitForServerLoadModel : (NSData *) data
{
    NSLog(@"get from server ... %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    if([_currentSelectedModel isKindOfClass:[MeshObj class]])
    {
        if ([((MeshObj *) _currentSelectedModel).ModelType compare:@"SPM"] == NSOrderedSame) {
            NSLog(@"get a spm base data info size");
            [_socketHandler socketSendMessageWithReadTimeOut:COMMAND_REQUEST_SPM_BASE_INFO_DATA_SIZE :SOCKET_WAIT_FOR_SPM_BASE_INFO_DATA_SIZE :-1];
        }
    }
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
    
    //try to retrieve all details.
    
    
}

- (void) syncViewingParametersToServer : (NSData *) viewing_parameters_
{
    NSLog(@"Sync Viewing Params with Server");
    [_socketHandler socketSendDataWithLengthAndReadTimeOut:viewing_parameters_:SOCKET_WAIT_FOR_SPM_VSPLIT_DATA_SIZE :-1];
    
}




@synthesize  serverInfo = _serverInfo;
@synthesize  currentSelectedModel = _currentSelectedModel;
@synthesize  progMeshModel = _progMeshModel;
@end
