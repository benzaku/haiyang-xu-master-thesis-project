//
//  Constants.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/27/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

FOUNDATION_EXPORT NSString *const DEFAULT_HOST;
FOUNDATION_EXPORT NSString *const DEFAULT_PORT;
FOUNDATION_EXPORT NSString *const SERVER_STATE_NOT_CONNECTED;
FOUNDATION_EXPORT NSString *const SERVER_STATE_CONNECTED;
FOUNDATION_EXPORT NSString *const BUTTON_TEXT_CONNECT;
FOUNDATION_EXPORT NSString *const BUTTON_TEXT_DISCONNECT;

enum SOCKET_STATE {SOCKET_CONNECTED_IDLE, SOCKET_NOT_CONNECTED_IDLE, SOCKET_WAIT_FOR_MODEL_LIST_SIZE , SOCKET_WAIT_FOR_MODEL_LIST, SOCKET_WAIT_FOR_HELLO, SOCKET_WAIT_SERVER_LOAD_MODEL };

FOUNDATION_EXPORT NSString *const COMMAND_REQUEST_MODEL_LIST_XML;

FOUNDATION_EXPORT NSString *const COMMAND_REQUEST_MODEL_LIST_XML_SIZE;

FOUNDATION_EXPORT NSString *const COMMAND_REQUEST_LOAD_MODEL;

FOUNDATION_EXPORT NSString *const HELLO_FROM_SERVER;

@end
