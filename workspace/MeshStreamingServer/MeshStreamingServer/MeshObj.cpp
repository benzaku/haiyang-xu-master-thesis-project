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

void
MeshObj::setMeshType(std::string &ext)
{
    if(ext.compare(PM) == 0){
        MeshType = PM;
    }
    else if(ext.compare(SPM) == 0){
        MeshType = SPM;
    } else{
        MeshType = UNKNOWTYPE;
    }
    
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
    
    AutoPtr<Element> objectFileId = doc->createElement("Id");
    AutoPtr<Text> fileId = doc->createTextNode(this->IdAsString);
    objectFileId->appendChild(fileId);
    aMesh->appendChild(objectFileId);
    
    AutoPtr<Element> meshType = doc->createElement("ModelType");
    AutoPtr<Text> type = doc->createTextNode(this->MeshType);
    meshType->appendChild(type);
    aMesh->appendChild(meshType);
    
    
    return aMesh;
    
}