//
//  MeshObj.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/23/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__MeshObj__
#define __MeshStreamingServer__MeshObj__

#include <iostream>
#include <string>
#include "Poco/DOM/Element.h"
#include "Poco/DOM/AutoPtr.h"
#include "Poco/DOM/Document.h"
#include "Poco/Dom/Text.h"


using Poco::XML::Element;
using Poco::XML::AutoPtr;
using Poco::XML::Document;
using Poco::XML::Text;

using namespace std;

#define SPM    "SPM"
#define PM      "PM"
#define UNKNOWTYPE  "UNKNOW"

class MeshObj
{
public:
    string  ObjectFilePath;
    string  RootDirPath;
    string  ObjectFileName;
    int     Id;
    string  IdAsString;
    string  MeshType;
    
    MeshObj();
    ~MeshObj();
    
    void setMeshType(std::string &ext);
    
    AutoPtr<Element> getXMLElement(AutoPtr<Document> &doc);
};

#endif /* defined(__MeshStreamingServer__MeshObj__) */
