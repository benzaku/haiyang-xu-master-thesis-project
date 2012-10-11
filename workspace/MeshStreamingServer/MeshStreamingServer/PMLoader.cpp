//
//  PMLoader.cpp
//  PMStreamServer
//
//  Created by Haiyang Xu on 9/14/12.
//  Copyright (c) 2012 SJTU. All rights reserved.
//

#include <iostream>
#include <fstream>
#include "PMLoader.h"


#include <OpenMesh/Core/Utils/Endian.hh>

PMLoader::PMLoader()
{
    this->baseMeshChunk = NULL;
    this->baseMeshChunkSize = 0;
}

PMLoader::PMLoader(std::string pmFileName)
{
    this->pmFileName = pmFileName;
    this->baseMeshChunk = NULL;
    this->baseMeshChunkSize = 0;
}

PMLoader::~PMLoader()
{
    
}

void
PMLoader::loadPM()
{
    
    MyMesh::Point  p;
    unsigned int   i, i0, i1, i2;
    unsigned int   v1, vl, vr;
    char           c[10];
    
    std::ifstream  ifs(this->pmFileName.c_str(), std::ios::binary);
    if (!ifs)
    {
        std::cerr << "read error\n";
        exit(1);
    }
    
    //
    bool swap = OpenMesh::Endian::local() != OpenMesh::Endian::LSB;
    
    // read header
    ifs.read(c, 8); c[8] = '\0';
    if (std::string(c) != std::string("ProgMesh"))
    {
        std::cerr << "Wrong file format.\n";
        exit(1);
    }
    OpenMesh::IO::binary<size_t>::restore( ifs, n_base_vertices_,   swap );
    OpenMesh::IO::binary<size_t>::restore( ifs, n_base_faces_,      swap );
    OpenMesh::IO::binary<size_t>::restore( ifs, n_detail_vertices_, swap );
    
    n_max_vertices_    = n_base_vertices_ + n_detail_vertices_;
    
    // load base mesh
    mesh_.clear();
    
    for (i=0; i<n_base_vertices_; ++i)
    {
        OpenMesh::IO::binary<MyMesh::Point>::restore( ifs, p, swap );
        mesh_.add_vertex(p);
    }
    
    for (i=0; i<n_base_faces_; ++i)
    {
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i0, swap);
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i1, swap);
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i2, swap);
        mesh_.add_face(mesh_.vertex_handle(i0), 
                       mesh_.vertex_handle(i1), 
                       mesh_.vertex_handle(i2));
    }
    
    
    // load progressive detail
    for (i=0; i<n_detail_vertices_; ++i)
    {
        OpenMesh::IO::binary<MyMesh::Point>::restore( ifs, p, swap );
        OpenMesh::IO::binary<unsigned int>::restore( ifs, v1, swap );
        OpenMesh::IO::binary<unsigned int>::restore( ifs, vl, swap );
        OpenMesh::IO::binary<unsigned int>::restore( ifs, vr, swap );
        
        PMInfo pminfo;
        pminfo.p0 = p;
        pminfo.v1 = MyMesh::VertexHandle(v1);
        pminfo.vl = MyMesh::VertexHandle(vl);
        pminfo.vr = MyMesh::VertexHandle(vr);
        pminfos_.push_back(pminfo);
        
    }
    pmiter_ = pminfos_.begin();
    
    
    // update face and vertex normals
    mesh_.update_face_normals();
    mesh_.update_vertex_normals();   
    
    // bounding box
    MyMesh::ConstVertexIter  
    vIt(mesh_.vertices_begin()), 
    vEnd(mesh_.vertices_end());
    
    MyMesh::Point bbMin, bbMax;
    
    bbMin = bbMax = mesh_.point(vIt);
    for (; vIt!=vEnd; ++vIt)
    {
        bbMin.minimize(mesh_.point(vIt));
        bbMax.maximize(mesh_.point(vIt));
    }
    
    // info
    std::cerr << mesh_.n_vertices() << " vertices, "
    << mesh_.n_edges()    << " edge, "
    << mesh_.n_faces()    << " faces, "
    << n_detail_vertices_ << " detail vertices\n";
    
    mesh_ptr = &mesh_;
    ifs.close();
}

char*
PMLoader::getDetailsChunk()
{
    int detailsChunkSize = this->getNDetailVertices() * 24;
    
    char * ret = new char[detailsChunkSize];
    
    char* buf = new char[1024];
    
    MyMesh::Point  p;
    unsigned int   i, i0, i1, i2;
    unsigned int   v1, vl, vr;
    char           c[10];
    size_t         temp;
    
    std::ifstream  ifs(this->pmFileName.c_str(), std::ios::binary);
    if (!ifs)
    {
        std::cerr << "read error\n";
        exit(1);
    }
    
    //
    bool swap = OpenMesh::Endian::local() != OpenMesh::Endian::LSB;
    
    // read header
    ifs.read(c, 8); c[8] = '\0';
    if (std::string(c) != std::string("ProgMesh"))
    {
        std::cerr << "Wrong file format.\n";
        exit(1);
    }
    OpenMesh::IO::binary<size_t>::restore( ifs, temp,   swap );
    OpenMesh::IO::binary<size_t>::restore( ifs, temp,      swap );
    OpenMesh::IO::binary<size_t>::restore( ifs, temp, swap );
    
        
    for (i=0; i<n_base_vertices_; ++i)
    {
        OpenMesh::IO::binary<MyMesh::Point>::restore( ifs, p, swap );
        
    }
    
    for (i=0; i<n_base_faces_; ++i)
    {
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i0, swap);
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i1, swap);
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i2, swap);
        
    }
    
    ifs.read(ret, detailsChunkSize);
    
    ifs.close();
    
    this->detailsChunk = ret;
    
    delete buf;
    
    return ret;
}


char*
PMLoader::getBaseMeshChunk()
{
    if(this->baseMeshChunk != NULL)
        return this->baseMeshChunk;
    MyMesh::Point  p;
    char           c[10];
    //char*          baseMeshChunk;
    
    std::ifstream  ifs(this->pmFileName.c_str(), std::ios::binary);
    if (!ifs)
    {
        std::cerr << "read error\n";
        exit(1);
    }
    
    //
    bool swap = OpenMesh::Endian::local() != OpenMesh::Endian::LSB;
    
    // read header
    ifs.read(c, 8); c[8] = '\0';
    if (std::string(c) != std::string("ProgMesh"))
    {
        std::cerr << "Wrong file format.\n";
        exit(1);
    }
    OpenMesh::IO::binary<size_t>::restore( ifs, n_base_vertices_,   swap );
    OpenMesh::IO::binary<size_t>::restore( ifs, n_base_faces_,      swap );
    OpenMesh::IO::binary<size_t>::restore( ifs, n_detail_vertices_, swap );
    
    n_max_vertices_    = n_base_vertices_ + n_detail_vertices_;
    
    // load base mesh
    baseMeshChunkSize = n_base_vertices_ * sizeof(MyMesh::Point) + n_base_faces_ * sizeof(unsigned int) * 3;
    std::cout<< "baseMeshChunkSize = " << baseMeshChunkSize << std::endl;
    char* baseMeshChunk = new char[baseMeshChunkSize];
    //mesh_.clear();
    
    ifs.read(baseMeshChunk, baseMeshChunkSize);
    /*
    for (i=0; i<n_base_vertices_; ++i)
    {
        OpenMesh::IO::binary<MyMesh::Point>::restore( ifs, p, swap );
        mesh_.add_vertex(p);
    }
    
    for (i=0; i<n_base_faces_; ++i)
    {
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i0, swap);
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i1, swap);
        OpenMesh::IO::binary<unsigned int>::restore( ifs, i2, swap);
        mesh_.add_face(mesh_.vertex_handle(i0), 
                       mesh_.vertex_handle(i1), 
                       mesh_.vertex_handle(i2));
    }
    
    */
    ifs.close();
    
    this->baseMeshChunk = baseMeshChunk;
    
    return baseMeshChunk;

}

PMInfoContainer 
PMLoader::getPMInfos()
{
    return pminfos_;
}

int
PMLoader::getBaseMeshChunkSize()
{
    return baseMeshChunkSize;
}

size_t 
PMLoader::getNBaseVertices(){
    return n_base_vertices_;
}

size_t 
PMLoader::getNBaseFaces(){
    return n_base_faces_;
}

size_t 
PMLoader::getNDetailVertices(){
    return n_detail_vertices_;
}

size_t 
PMLoader::getNMaxVertices(){
    return n_max_vertices_;
}

MyMesh* 
PMLoader::getBaseMesh(){
    return mesh_ptr;
}