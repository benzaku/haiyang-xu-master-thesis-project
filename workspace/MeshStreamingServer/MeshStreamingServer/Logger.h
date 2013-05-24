//
//  Logger.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 16.05.13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__Logger__
#define __MeshStreamingServer__Logger__

#include <iostream>
#include <ctime>
#include <sstream>

#include "Poco/Logger.h"
#include "Poco/PatternFormatter.h"
#include "Poco/FormattingChannel.h"
#include "Poco/ConsoleChannel.h"
#include "Poco/FileChannel.h"
#include "Poco/Message.h"
#include "Util/Singleton.h"

using Poco::Logger;
using Poco::PatternFormatter;
using Poco::FormattingChannel;
using Poco::ConsoleChannel;
using Poco::FileChannel;
using Poco::Message;

class SysLogger{
    
    
public:
    
    Logger * fileLogger;
    
    Poco::FormattingChannel* pFCFile;
    
    void createLogFile(){
        std::stringstream ss;
        ss << time(0);
        
        pFCFile->setChannel(new FileChannel("system_"+ss.str()+".log"));
        pFCFile->open();
        fileLogger    = &(Logger::create("FileLogger", pFCFile, Message::PRIO_WARNING));
    };
    
    void clear(){
            };
    
    void log(std::string info){
        fileLogger->error(info);
    };
    SysLogger(){
        
        pFCFile = new FormattingChannel(new PatternFormatter("%H:%M:%S.%i\t%t"));

        fileLogger = NULL;
        
    };
    ~SysLogger(){
       
    };
};

#endif /* defined(__MeshStreamingServer__Logger__) */
