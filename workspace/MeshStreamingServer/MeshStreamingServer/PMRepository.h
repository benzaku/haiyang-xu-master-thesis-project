//
//  PMRepository.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/16/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__PMRepository__
#define __MeshStreamingServer__PMRepository__

#include <iostream>
#include "Singleton.h"
#include <string>
#include <vector>
#include <dirent.h>
#include "VolumeObj.h"
#include "MeshObj.h"

using namespace std;

class PMRepository
{
private:
    string *repositoryDir;    //repository directory path
    
    string *PROG_MESH;
    string *VOLUME;
    string *FILE_SEPARATOR;
    
    int volumeNumber;
    int meshNumber;
    
    vector<VolumeObj> volumeObjs;
    
    vector<MeshObj> meshObjs;
    
    void inline initVar();
    
    
public:
    ~PMRepository();
    
    PMRepository(string *repository);
    PMRepository();
    
    string* getRepositoryDir();
    void setRepositoryDir(string *repo);
    string *getProgMeshDir();
    string *getVolumeDir();
    int getMeshNumber();
    int getVolumeNumber();
    string *getProgMeshFileNames();
    string *getVolumeFileNames();
    vector<string> readDirectory(const string &directoryLocation, const string &extension);
    vector<string> getSubDirectories(const string &rootDirectoryLocation);
    
    void initVolumeObjs();
    
    void initMeshObjs();
    
    vector<VolumeObj> * getVolumeObjs();
    vector<MeshObj> * getMeshObjs();

};

#endif /* defined(__MeshStreamingServer__PMRepository__) */
