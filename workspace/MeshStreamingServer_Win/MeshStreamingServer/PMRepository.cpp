//
//  PMRepository.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/16/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#include "PMRepository.h"
#include <stdlib.h>
#include <stdio.h>;
#include <string>
#include <exception>
#include <fstream>
#include <Poco/StringTokenizer.h>
#include <Poco/String.h>
#include <iostream>
#include <sstream>
#include <time.h>

using namespace std;


string*
PMRepository::getRepositoryDir(){
    return repositoryDir;
}

void
PMRepository::setRepositoryDir(std::string *repo)
{
    this->repositoryDir = repo;
}

string*
PMRepository::getProgMeshDir(){
    
    string *str = new string(repositoryDir->c_str());
    str->append(*FILE_SEPARATOR);
    str->append(*PROG_MESH);
    
    return str;
}

inline
std::string
get_extension( std::string& _s)
{
    std::string::size_type dot = _s.rfind(".");
    
    return _s.substr(dot+1);
    
}

void stringToUpper(string &s)
{
    for(unsigned int l = 0; l < s.length(); l++)
    {
        s[l] = toupper(s[l]);
    }
}

string*
PMRepository::getVolumeDir(){
    
    string *str = new string(repositoryDir->c_str());
    str->append(*FILE_SEPARATOR);
    str->append(*VOLUME);
    
    return str;
}

int
PMRepository::getMeshNumber()
{
    return meshNumber;
}

int
PMRepository::getVolumeNumber()
{
    return volumeNumber;
}


string * PMRepository::getProgMeshFileNames(){
    return NULL;
}

string *
PMRepository::getVolumeFileNames()
{
    
    
    
    return NULL;
}

PMRepository::PMRepository(){
    initVar();
    
}

void inline
PMRepository::initVar(){
    PROG_MESH = new string("mesh");
    VOLUME = new string("volume");
    FILE_SEPARATOR = new string("/");
    volumeNumber = 0;
    srand( (unsigned int)time(NULL) );
    incrementalId = rand();
}

PMRepository::~PMRepository(){
    
}

PMRepository::PMRepository(string *repository){
    repositoryDir = new string(repository->c_str());
    initVar();
    
    
    
}

char * strToLower(const string &str){
    int len = (int)str.length();
    char * rtn = new char[len];
    strcpy(rtn, str.c_str());
    for(int i = 0; i < len; i ++){
        rtn[i] = tolower(rtn[i]);
    }
    return rtn;
}

/**
 * Read a directory listing into a vector of strings, filtered by file extension.
 * Throws std::exception on error.
 **/
vector<string>
PMRepository::readDirectory(const string &directoryLocation, const string &extension){
    vector<string> result;
    string lcExtension( strToLower(extension) );
	
    DIR *dir;
    struct dirent *ent;
    
    if ((dir = opendir(directoryLocation.c_str())) == NULL) {
        throw std::exception();
    }
    
    while ((ent = readdir(dir)) != NULL)
    {
        string entry( ent->d_name );
        string lcEntry( strToLower(entry) );
        
        
        // Check extension matches (case insensitive)
        size_t pos = lcEntry.rfind(lcExtension);
        if (pos!=string::npos && pos==lcEntry.length()-lcExtension.length() ) {
            result.push_back( entry );
        }
    }
    
    if (closedir(dir) != 0) {
    	throw std::exception();
    }
    
    return result;
}

vector<string>
PMRepository::getSubDirectories(const string &rootDirectoryLocation)
{
    vector<string> result;
    DIR *dir;
    struct dirent *ent;
    
    if((dir = opendir(rootDirectoryLocation.c_str())) == NULL){
        throw std::exception();
    }
    
    while ((ent = readdir(dir)) != NULL) {
        string entry(ent->d_name);
        string lcEntry(strToLower(entry));
        if(ent->d_type == DT_DIR && strcmp(ent->d_name, ".") != 0 && strcmp(ent->d_name, "..") != 0){
            result.push_back(entry);
        }
    }
    if (closedir(dir) != 0) {
        throw std::exception();
    }
    return result;
}

void
PMRepository::initVolumeObjs()
{
    string * volRootDirName = getVolumeDir();
    char currentVolRootDir[1024];
    char filefullpath[1024];
    vector<string> volDirNames = getSubDirectories(*volRootDirName);
    string str1, str2;
    char temp[512];
    for(int i = 0; i < volDirNames.size(); i ++){
        strcpy(filefullpath, volRootDirName->c_str());
        strcat(filefullpath, FILE_SEPARATOR->c_str());
        strcat(filefullpath, volDirNames[i].c_str());
        strcpy(currentVolRootDir, filefullpath);
        strcat(filefullpath, FILE_SEPARATOR->c_str());
        strcat(filefullpath, readDirectory(filefullpath, "dat")[0].c_str());
        std::ifstream infile(filefullpath);
        string line;
        
        VolumeObj *vObj = new VolumeObj();
        
        while (std::getline(infile, line)) {
            
            vObj->RootDirPath = currentVolRootDir;
            Poco::StringTokenizer stn(line, ":");
            vObj->PropertiesMap.insert(std::pair<string, string>(Poco::trim(stn[0]), Poco::trim(stn[1])));
            
            
        }
        incrementalId ++;
        
        ostringstream convert;   // stream used for the conversion
        
        convert << incrementalId;
        
        vObj->PropertiesMap.insert(std::pair<string, string>("Id", convert.str()));
        vObj->Id = incrementalId;
        
        vObj->PropertiesMap.insert(std::pair<string, string>("ModelType", "VOL"));
        
        vObj->ObjectFileName = vObj->PropertiesMap.at("ObjectFileName");
        strcpy(temp, volRootDirName->c_str());
        strcat(temp, FILE_SEPARATOR->c_str());
        strcat(temp, vObj->PropertiesMap.at("ObjectFileName").c_str());
        vObj->ObjectFilePath = *(new string(temp));
        volumeObjs.push_back(vObj);
        infile.close();
        
    }
    volumeNumber = (int)volumeObjs.size();
    
}

void
PMRepository::initMeshObjs()
{
    string * meshRootDirName = getProgMeshDir();
    vector<string> meshDirNames = readDirectory(*meshRootDirName, "pm");
    char filepath[1024];
    for(int i = 0; i < meshDirNames.size(); i ++){
        MeshObj* mObj = new MeshObj();
        strcpy(filepath, meshRootDirName->c_str());
        strcat(filepath, FILE_SEPARATOR->c_str());
        strcat(filepath, meshDirNames[i].c_str());
        
        mObj->ObjectFilePath = filepath;
        mObj->RootDirPath = *meshRootDirName;
        mObj->ObjectFileName = meshDirNames[i];
        
        std::string f(filepath);
        
        std::string ext = get_extension(f);
        stringToUpper(ext);
        
        mObj->setMeshType(ext);
        
        incrementalId ++;
        mObj->Id = incrementalId;
        
        ostringstream convert;   // stream used for the conversion
        
        convert << incrementalId;
        mObj->IdAsString = convert.str();
        
        meshObjs.push_back(mObj);
    }
    meshNumber = (int) meshObjs.size();
}

vector<VolumeObj*> *
PMRepository::getVolumeObjs()
{
    return &volumeObjs;
}

vector<MeshObj*> *
PMRepository::getMeshObjs()
{
    return &meshObjs;
}


AutoPtr<Document>
PMRepository::getModelObjectsXmlDocument()
{
    
    AutoPtr<Document> rootDoc = new Document;
    
    AutoPtr<Element> modelRoot = rootDoc->createElement("Models");
    
    AutoPtr<Element> rootVolElement = rootDoc->createElement("VolumeObjects");
    
    
    for(int i = 0; i < volumeObjs.size(); i ++){
        AutoPtr<Element> volElement = volumeObjs[i]->getXMLElement(rootDoc);
        rootVolElement->appendChild(volElement);
    }
    modelRoot->appendChild(rootVolElement);
    
    AutoPtr<Element> rootMeshElement = rootDoc->createElement("MeshObjects");
    for(int i = 0; i < meshObjs.size(); i ++){
        AutoPtr<Element> meshElement = meshObjs[i]->getXMLElement(rootDoc);
        rootMeshElement->appendChild(meshElement);
    }
    modelRoot->appendChild(rootMeshElement);
    
    rootDoc->appendChild(modelRoot);
    
    return rootDoc;
}

void
PMRepository::generateModelListXmlInfo()
{
    
    AutoPtr<Document> pDoc = this->getModelObjectsXmlDocument();
    
    
    DOMWriter writer;
    writer.setNewLine("\n");
    writer.setOptions(XMLWriter::PRETTY_PRINT);
    
    
    std::stringstream str;
    
    writer.writeNode(str, pDoc);
    
    modelListXmlString = (char *)(str.str().c_str());
    
    modelListXmlStringLength = (int)(str.str().length());
    
}

char *
PMRepository::getModelListXmlString()
{
    return this->modelListXmlString;
}

int PMRepository::getModelListXmlStringLength()
{
    return this->modelListXmlStringLength;
}


