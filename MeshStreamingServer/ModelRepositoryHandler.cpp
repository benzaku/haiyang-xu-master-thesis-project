//
//  ModelRepositoryHandler.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/23/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#include "ModelRepositoryHandler.h"
void
ModelRepositoryHandler::setPMRepository(PMRepository * pmrepo)
{
    this->_PMRepository = pmrepo;
}


PMRepository *
ModelRepositoryHandler::getPMRepository()
{
    return this->_PMRepository;
}