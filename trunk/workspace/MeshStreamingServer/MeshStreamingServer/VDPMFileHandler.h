//
//  VDPMFileHandler.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 1/13/13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__VDPMFileHandler__
#define __MeshStreamingServer__VDPMFileHandler__

#include <iostream>

#include "VDPMLoader.h"
#include "Util/Singleton.h"

class VDPMFileHandler : public Singleton{
    
private:    
    
public:
    
    
    VDPMLoader * getVDPMLoader(){
        return vdpmLoader;
    };
    
    void setVDPMLoader(VDPMLoader * loader){
        this->vdpmLoader = loader;
    };
    
    void clear(){
        if(vdpmLoader != NULL){
            delete vdpmLoader;
            vdpmLoader = NULL;
        }
    }
    
private:
    
    VDPMFileHandler();
    ~VDPMFileHandler();
        
    VDPMLoader* vdpmLoader;
    
    

};

#endif /* defined(__MeshStreamingServer__VDPMFileHandler__) */
