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
#include "Poco/DOM/Document.h"
#include "Poco/DOM/Element.h"
#include "Poco/DOM/Text.h"
#include "Poco/DOM/AutoPtr.h"
#include "Poco/DOM/DOMWriter.h"
#include "Poco/XML/XMLWriter.h"

using Poco::XML::Document;
using Poco::XML::Element;
using Poco::XML::Text;
using Poco::XML::AutoPtr;
using Poco::XML::DOMWriter;
using Poco::XML::XMLWriter;

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
    
    char *modelListXmlString;
    int modelListXmlStringLength;
    
    vector<VolumeObj*> volumeObjs;
    
    vector<MeshObj*> meshObjs;
    
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
    
    vector<VolumeObj*> * getVolumeObjs();
    vector<MeshObj*> * getMeshObjs();
    
    AutoPtr<Document> getModelObjectsXmlDocument();
    
    void generateModelListXmlInfo();
    
    char * getModelListXmlString();
    
    int getModelListXmlStringLength();
    
};

#endif /* defined(__MeshStreamingServer__PMRepository__) */
