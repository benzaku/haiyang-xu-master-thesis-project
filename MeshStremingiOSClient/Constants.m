//
//  Constants.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/27/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const DEFAULT_HOST = @"192.168.1.3";
NSString *const DEFAULT_PORT = @"9977";
NSString *const SERVER_STATE_NOT_CONNECTED = @"Server NOT Connected";
NSString *const SERVER_STATE_CONNECTED = @"Server Connected";

NSString *const BUTTON_TEXT_CONNECT = @"Connect";
NSString *const BUTTON_TEXT_DISCONNECT = @"Disconnect";

NSString *const COMMAND_REQUEST_MODEL_LIST_XML = @"MODEL_LIST";

NSString *const COMMAND_REQUEST_MODEL_LIST_XML_SIZE = @"SIZE_OF_MODEL_LIST";

NSString *const COMMAND_REQUEST_SPM_BASE_INFO_DATA_SIZE = @"SPM_BASE_INFO_DATA_SIZE";
NSString *const COMMAND_REQUEST_SPM_BASE_INFO_DATA = @"SPM_BASE_INFORMATION_DATA";

NSString *const COMMAND_SYNC_SPM_VIEWING_PARAMS = @"SYNC_SPM_VIEWING_PARAMS";
NSString *const COMMAND_RETIEVE_SPM_VSPLIT_DATA = @"RETRIEVE_SPM_VSPLIT_DATA";
NSString *const COMMAND_RETIEVE_SPM_VSPLIT_DATA_IDX_NUM = @"RETRIEVE_VSPLIT_DATA_IDX_NUM";


NSString *const HELLO_FROM_SERVER = @"HELLO";

NSString *const COMMAND_REQUEST_LOAD_MODEL = @"LOAD_MODEL";

NSString *const COMMAND_RETIEVE_SPM_DETAILS = @"VDPMDETAILS";

@end
