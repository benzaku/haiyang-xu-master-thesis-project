//
//  PMStreamServerHandler.h
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#ifndef PMStreamServer_PMStreamServerHandler_h
#define PMStreamServer_PMStreamServerHandler_h

#include "Poco/Net/StreamSocket.h"
#include "Poco/Net/SocketReactor.h"
#include "Poco/Net/SocketNotification.h"
#include "PMFileHandler.h"
#include "ModelRepositoryHandler.h"
#include "VDPMFileHandler.h"

using Poco::Net::StreamSocket;
using Poco::Net::SocketReactor;
using Poco::Net::ReadableNotification;
using Poco::Net::ShutdownNotification;
using Poco::AutoPtr;

class PMStreamServerHandler
{
public:
    PMStreamServerHandler(StreamSocket& socket, SocketReactor& reactor);
    
    ~PMStreamServerHandler();
    
    void onReadable(const AutoPtr<ReadableNotification>& pNf);
    
    void onShutdown(const AutoPtr<ShutdownNotification>& pNf);
    
private:
    enum
    {
        BUFFER_SIZE = 65536
        //BUFFER_SIZE = 65536
    };
    enum
    {
        PM_STATE, VDPM_STATE, VOL_STATE, NONE_STATE
    };
    
    int STREAM_STATE;
    
    StreamSocket        _socket;
    SocketReactor&      _reactor;
    char*               _pBuffer;
    int                 _tag;
    PMFileHandler*      _pmFH;
    ModelRepositoryHandler* _mRH;
    VDPMFileHandler*    _vdpmFH;
    
    int                 _temp;
    char*               _tempContentPtr;
    int                 _templen;
    char*               pmInfoChunk;
    
    data_chunk          *temp_data_chunk;
    int                 current_idx;
    
    
    bool handleLoadModelRequest(int modelId);
    
    int  getSPMBaseInfoDataSize();
    
    void handleRequest();

};

#endif
