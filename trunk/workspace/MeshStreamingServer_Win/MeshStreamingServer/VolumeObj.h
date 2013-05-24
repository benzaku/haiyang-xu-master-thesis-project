//
//  VolumeObj.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/23/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__VolumeObj__
#define __MeshStreamingServer__VolumeObj__

#include <iostream>
#include <map>
#include "Poco/DOM/Element.h"
#include "Poco/DOM/AutoPtr.h"
#include "Poco/DOM/Document.h"
#include "Poco/Dom/Text.h"

using namespace std;
using Poco::XML::Element;
using Poco::XML::AutoPtr;
using Poco::XML::Document;
using Poco::XML::Text;

class VolumeObj{
public:
    string  ObjectFileName;
    string  TaggedFileName;
    int     Resolution[3];
    float   SliceThickness[3];
    string  Format;
    int     NbrTags;
    string  ObjectType;
    string  ObjectModel;
    string  GridType;
    
    string  ObjectFilePath;
    string  RootDirPath;
    int     Id;
    
    map<string, string>     PropertiesMap;
    
    VolumeObj();
    ~VolumeObj();
    
    AutoPtr<Element> getXMLElement(AutoPtr<Document> &doc);
    
    
};


#endif /* defined(__MeshStreamingServer__VolumeObj__) */
