//
//  PublicIncludes.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 1/24/13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//

#ifndef MeshStreamingServer_PublicIncludes_h
#define MeshStreamingServer_PublicIncludes_h
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>

#include <OpenMesh/Tools/VDPM/MeshTraits.hh>
using namespace OpenMesh;
using namespace OpenMesh::VDPM;
typedef TriMesh_ArrayKernelT<VDPM::MeshTraits>	VDPMMesh;

struct viewparam {
    double      modelViewMatrix[16];
    float       aspect;
    float       fovy;
    float       tolerance_square;
};

struct data_chunk {
    char    HEADER[8];
    int     size;
    char *  data;
};


#endif
