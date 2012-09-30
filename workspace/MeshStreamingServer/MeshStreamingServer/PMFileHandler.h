//
//  PMFileHandler.h
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/13/12.
//  Copyright (c) 2012. All rights reserved.
//

#ifndef PMStreamServer_PMFileHandler_h
#define PMStreamServer_PMFileHandler_h

#include <fstream>
#include "Util/Singleton.h"
#include <iostream>
#include "unistd.h"
#include "PMLoader.h"

using namespace std;

class PMFileHandler : public Singleton
{
public:
    void setFileName(std::string& fileName);
    std::string* getFileName();
    std::ifstream* getPMFileStream();
    PMLoader* getPMLoader();
    void setPMLoader(PMLoader* pmLoader);
    
private:
    std::string * fileName;
    std::ifstream * pmFileStream;
    PMFileHandler();
    ~PMFileHandler();
    PMLoader* pmLoader;
    
};

#endif
