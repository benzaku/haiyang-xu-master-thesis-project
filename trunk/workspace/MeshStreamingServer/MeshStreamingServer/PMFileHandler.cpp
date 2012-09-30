//
//  PMFileHandler.cpp
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/14/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#include <iostream>
#include "PMFileHandler.h"

using namespace std;




void
PMFileHandler::setFileName(std::string& fileName)
{
    
    this->fileName = &fileName;
    pmFileStream = new std::ifstream(fileName.c_str());
}

std::string*
PMFileHandler::getFileName()
{
    return fileName;
}

std::ifstream*
PMFileHandler::getPMFileStream()
{
    if (pmFileStream == NULL) {
        pmFileStream = new std::ifstream(fileName->c_str());
    }
    return pmFileStream;
}

PMLoader*
PMFileHandler::getPMLoader()
{
    return pmLoader;
}

void 
PMFileHandler::setPMLoader(PMLoader* pmLoader)
{
    this->pmLoader = pmLoader;
}

