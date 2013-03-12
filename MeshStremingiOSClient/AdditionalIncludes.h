//
//  AdditionalIncludes.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/15/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#ifndef __MeshStremingiOSClient__AdditionalIncludes__
#define __MeshStremingiOSClient__AdditionalIncludes__

#include <iostream>
#include <istream>
#include <streambuf>
#include <string>
#include <set>

#include <OpenMesh/Tools/VDPM/MeshTraits.hh>
#include <OpenMesh/Tools/VDPM/StreamingDef.hh>
#include <OpenMesh/Tools/VDPM/ViewingParameters.hh>
#include <OpenMesh/Tools/VDPM/VHierarchy.hh>
#include <OpenMesh/Tools/VDPM/VFront.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>


#define M_PI        3.14159265358979323846264338327950288   /* pi             */


using namespace OpenMesh;
using namespace OpenMesh::VDPM;

struct membuf : std::streambuf
{
    membuf(char* begin, char* end) {
        this->setg(begin, begin, end);
    }
};

typedef TriMesh_ArrayKernelT<VDPM::MeshTraits>	VDPMMesh;


struct Vsplit {
    OpenMesh::Vec3f v0;     //position of v0
    //vsplit info
    unsigned int    node_index;
    unsigned int    fund_lcut_index;
    unsigned int    fund_rcut_index;
    
    float           l_radius;
    OpenMesh::Vec3f l_normal;
    float           l_sin_square;
    float           l_mue_square;
    float           l_sigma_square;
    
    float           r_radius;
    OpenMesh::Vec3f r_normal;
    float           r_sin_square;
    float           r_mue_square;
    float           r_sigma_square;
    
};

#include <set.h>

typedef std::set<int>          UpdatePartIndex;
typedef std::pair<UpdatePartIndex *, UpdatePartIndex *> UpdateInfo;
#endif /* defined(__MeshStremingiOSClient__AdditionalIncludes__) */
