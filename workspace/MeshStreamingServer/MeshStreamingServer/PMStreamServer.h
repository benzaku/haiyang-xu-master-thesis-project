//
//  PMStreamServer.h
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#ifndef PMStreamServer_PMStreamServer_h
#define PMStreamServer_PMStreamServer_h


#include <iostream>
#include <fstream>
#include "Poco/Util/ServerApplication.h"
#include "Poco/Util/Option.h"
#include "Poco/Util/OptionSet.h"
#include "PMFileHandler.h"
#include "PMLoader.h"
#include "PMRepository.h"

using Poco::Util::ServerApplication;
using Poco::Util::Option;
using Poco::Util::OptionSet;

class PMStreamServer: public Poco::Util::ServerApplication
{
public:
	PMStreamServer();
	
	~PMStreamServer();
    
protected:
    
    void initialize(Application& self);
    
    void uninitialize();
    
    void defineOptions(OptionSet& options);
    
    void handleOption(const std::string& name, const std::string& value);
    
    void displayHelp();
    
	int main(const std::vector<std::string>& args);	

private:
    bool _helpRequested;
    std::string PMFileName;
    PMFileHandler* pmFileHandler;
    PMLoader* pmLoader;
    
    PMRepository *modelRepo;
    
    bool useVolume = false;
    
};

#endif
