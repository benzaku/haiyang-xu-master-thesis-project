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

using namespace std;

class PMRepository
{
private:
    string *repositoryDir;    //repository directory path
    
    string *PROG_MESH;
    string *VOLUME;
    string *FILE_SEPARATOR;
    
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
int getVolumeNumer();
string * getProgMeshFileNames();
string * getVolumeFileNames();
    vector<string> readDirectory(const string &directoryLocation, const string &extension);

};

#endif /* defined(__MeshStreamingServer__PMRepository__) */
