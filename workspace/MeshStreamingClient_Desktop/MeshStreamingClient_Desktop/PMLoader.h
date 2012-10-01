//
//  PMLoader.h
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/14/12.
//  Copyright (c) 2012 . All rights reserved.
//

#ifndef PMStreamServer_PMLoader_h
#define PMStreamServer_PMLoader_h


#include <OpenMesh/Core/Mesh/Attributes.hh>
#include <OpenMesh/Core/IO/BinaryHelper.hh>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>
#include <string>


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
class PMLoader
{
public:
    PMLoader();
    
    PMLoader(std::string pmFileName);
    
    ~PMLoader();
    
    void loadPM();
    
    size_t getNBaseVertices();
    
    size_t getNBaseFaces();
    
    size_t getNDetailVertices();
    
    size_t getNMaxVertices();
    
    MyMesh* getBaseMesh();
    
    PMInfoContainer getPMInfos();
    
    
private:
    
    
    PMInfoContainer   pminfos_;
    PMInfoIter        pmiter_;                                              //pm info iterator
    size_t            n_base_vertices_, n_base_faces_, n_detail_vertices_;
    size_t            n_max_vertices_;                                      //# max vertieces
    MyMesh            mesh_;                                                //base mesh
    MyMesh*           mesh_ptr;
    
    std::string pmFileName;
};


#endif
