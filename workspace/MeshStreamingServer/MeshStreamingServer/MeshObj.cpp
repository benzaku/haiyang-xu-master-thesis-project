//
//  MeshObj.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/23/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#include "MeshObj.h"

MeshObj::MeshObj()
{
    
}
MeshObj::~MeshObj()
{
    
}

AutoPtr<Element>
MeshObj::getXMLElement(AutoPtr<Document> &doc)
{
    AutoPtr<Element> aMesh = doc->createElement("MeshObj");
    AutoPtr<Element> objectFilePath = doc->createElement("ObjectFilePath");
    AutoPtr<Text> pathText = doc->createTextNode(this->ObjectFilePath);
    objectFilePath->appendChild(pathText);
    aMesh->appendChild(objectFilePath);
    
    AutoPtr<Element> rootDirPath = doc->createElement("RootDirPath");
    AutoPtr<Text> rootPath = doc->createTextNode(this->RootDirPath);
    rootDirPath->appendChild(rootPath);
    aMesh->appendChild(rootDirPath);
    
    AutoPtr<Element> objectFileName = doc->createElement("ObjectFileName");
    AutoPtr<Text> fileName = doc->createTextNode(this->ObjectFileName);
    objectFileName->appendChild(fileName);
    aMesh->appendChild(objectFileName);
    
    
    return aMesh;
    
}