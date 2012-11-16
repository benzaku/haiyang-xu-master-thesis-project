//
//  PMRepository.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/16/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#include "PMRepository.h"
#include <string>
#include <exception>



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
    return 0;
}

int
PMRepository::getVolumeNumer()
{
    return 0;
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
        if (pos!=string::npos && pos==lcEntry.length()-lcExtension.length()) {
            result.push_back( entry );
        }
    }
    
    if (closedir(dir) != 0) {
    	throw std::exception();
    }
    
    return result;
}


