//
//  PMLoader.h
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/14/12.
//  Copyright (c) 2012 . All rights reserved.
//

#ifndef PMStreamServer_PMLoader_h
#define PMStreamServer_PMLoader_h

/*
#include <OpenMesh/Core/Mesh/Attributes.hh>
#include <OpenMesh/Core/IO/BinaryHelper.hh>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>
 */
#include <string>
#include "MC.h"
#include "PMTypes.h"

#define PM_REPO "./pm_repo/"

class PMLoader 
{
public:
    PMLoader();
    
    PMLoader(std::string pmFileName);
    
    ~PMLoader();
    
    void loadPM();
    
    size_t getNBaseVertices();
    
    size_t getNBaseFaces();
    
    size_t getNDetailVertices();
    
    size_t getNMaxVertices();
    
    MyMesh* getBaseMesh();
    
    char * getBaseMeshChunk();
    
    char * getDetailsChunk();
    
    int getBaseMeshChunkSize();
    
    PMInfoContainer getPMInfos();
    
    void enableVolume();
    
    void disableVolume();
    
    void setUseVolume(bool useornot);
    
private:
    
    void loadFromPMFile();
    
    void loadFromRawVolume();
        
    PMInfoContainer   pminfos_;
    PMInfoIter        pmiter_;                                              //pm info iterator
    size_t            n_base_vertices_, n_base_faces_, n_detail_vertices_;  
    size_t            n_max_vertices_;                                      //# max vertieces
    MyMesh            mesh_;                                                //base mesh
    MyMesh*           mesh_ptr;
    
    std::string pmFileName;
    
    bool              useVolume = false;
    
    int               baseMeshChunkSize;
    char*             baseMeshChunk;
    char*             detailsChunk;
};


#endif
