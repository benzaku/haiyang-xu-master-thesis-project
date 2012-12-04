//
//  VolumeObj.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/23/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#include "VolumeObj.h"

VolumeObj::VolumeObj(){
    Resolution[0] = 0;
    Resolution[1] = 0;
    Resolution[2] = 0;
    SliceThickness[0] = 0;
    SliceThickness[1] = 0;
    SliceThickness[2] = 0;
    NbrTags = 0;
}

VolumeObj::~VolumeObj(){
    
}

AutoPtr<Element>
VolumeObj::getXMLElement(AutoPtr<Document> &doc)
{
    AutoPtr<Element> aVolume = doc->createElement("VolumeObj");
    AutoPtr<Element> objectFilePath = doc->createElement("ObjectFilePath");
    AutoPtr<Text> pathText = doc->createTextNode(this->ObjectFilePath);
    objectFilePath->appendChild(pathText);
    aVolume->appendChild(objectFilePath);
    
    AutoPtr<Element> rootDirPath = doc->createElement("RootDirPath");
    AutoPtr<Text> rootPath = doc->createTextNode(this->RootDirPath);
    rootDirPath->appendChild(rootPath);
    aVolume->appendChild(rootDirPath);
    
    map<string, string>::iterator propiter;
    propiter = PropertiesMap.begin();
    for(; propiter != PropertiesMap.end(); ++propiter){
        AutoPtr<Element> property = doc->createElement(propiter->first);
        AutoPtr<Text> propertyValue = doc->createTextNode(propiter->second);
        property->appendChild(propertyValue);
        aVolume->appendChild(property);
    }
    
    return aVolume;
    
}