//
//  PMStruct.h
//  MeshStreamingClient_iOS
//
//  Created by Haiyang Xu on 04.10.12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingClient_iOS__PMStruct__
#define __MeshStreamingClient_iOS__PMStruct__

#include <iostream>
#include "OpenMesh/Core/Mesh/Attributes.hh"


#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>


using namespace OpenMesh;
using namespace OpenMesh::Attributes;

struct MyTraits : public OpenMesh::DefaultTraits
{
    VertexAttributes  ( OpenMesh::Attributes::Normal       |
                       OpenMesh::Attributes::Status       );
    EdgeAttributes    ( OpenMesh::Attributes::Status       );
    HalfedgeAttributes( OpenMesh::Attributes::PrevHalfedge );
    FaceAttributes    ( OpenMesh::Attributes::Normal       |
                       OpenMesh::Attributes::Status       );
};




typedef OpenMesh::TriMesh_ArrayKernelT<MyTraits>  MyMesh;


struct PMInfo
{
    MyMesh::Point        p0;
    MyMesh::VertexHandle v0, v1, vl, vr;
};
typedef std::vector<PMInfo>          PMInfoContainer;
typedef PMInfoContainer::iterator    PMInfoIter;

struct membuf : std::streambuf
{
    membuf(char* begin, char* end) {
        this->setg(begin, begin, end);
    }
};

#endif /* defined(__MeshStreamingClient_iOS__PMStruct__) */
