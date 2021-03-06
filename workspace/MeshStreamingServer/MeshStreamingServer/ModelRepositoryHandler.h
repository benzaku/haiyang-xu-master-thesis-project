//
//  ModelRepositoryHandler.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/23/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__ModelRepositoryHandler__
#define __MeshStreamingServer__ModelRepositoryHandler__

#include <iostream>
#include "Util/Singleton.h"
#include "PMRepository.h"

using namespace std;

class ModelRepositoryHandler : public Singleton{
    
public:
    void setPMRepository(PMRepository * pmrepo);
    
    PMRepository * getPMRepository();
    
private:
    ModelRepositoryHandler();
    ~ModelRepositoryHandler();
    PMRepository *_PMRepository;
};

#endif /* defined(__MeshStreamingServer__ModelRepositoryHandler__) */
