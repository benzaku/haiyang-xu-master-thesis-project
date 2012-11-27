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

using namespace std;

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
    
    map<string, string>     PropertiesMap;
    
    
};


#endif /* defined(__MeshStreamingServer__VolumeObj__) */
