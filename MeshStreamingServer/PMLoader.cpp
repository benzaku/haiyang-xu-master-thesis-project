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

inline
std::string&
replace_extension( std::string& _s, const std::string& _e )
{
    std::string::size_type dot = _s.rfind(".");
    if (dot == std::string::npos)
    { _s += "." + _e; }
    else
    { _s = _s.substr(0,dot+1)+_e; }
    return _s;
}

inline
std::string
basename(const std::string& _f)
{
    std::string::size_type dot = _f.rfind("/");
    if (dot == std::string::npos)
        return _f;
    return _f.substr(dot+1, _f.length()-(dot+1));
}


void
PMLoader::loadPM(){
    if(useVolume){
        loadFromRawVolume();
    } else {
        loadFromPMFile();
    }
}

void
PMLoader::loadFromRawVolume(){
    std::ifstream::pos_type size;
    char * memblock;
    MarchingCubes<unsigned char> mc;
    MyMesh::Point p;
    MyMesh::Normal normal;
    
    std::ifstream file (this->pmFileName.c_str(), std::ios::in|std::ios::binary|std::ios::ate);
    
    if (file.is_open())
    {
        size = file.tellg();
        memblock = new char [size];
        file.seekg (0, std::ios::beg);
        file.read (memblock, size);
        file.close();
        
        std::cout << "the complete file content is in memory\n";
        
        mc.SetVolume(128, 128, 128, (unsigned char *)memblock);
        mc.Process(20);
        Isosurface *isoSurface = mc.m_Isosurface;
        delete[] memblock;
        mesh_.clear();
        mesh_.request_vertex_normals();
        mesh_.request_face_normals();
        
        for(int i = 0; i < isoSurface->iVertices; i ++){
            p[0] = isoSurface->vfVertices[i][0];
            p[1] = isoSurface->vfVertices[i][1];
            p[2] = isoSurface->vfVertices[i][2];
            mesh_.add_vertex(p);
            
            normal[0] = isoSurface->vfNormals[i][0];
            normal[1] = isoSurface->vfNormals[i][1];
            normal[2] = isoSurface->vfNormals[i][2];
            mesh_.set_normal(mesh_.vertex_handle(i), normal);
        }
        
        for (int i = 0; i < isoSurface->iTriangles; i ++) {
            mesh_.add_face(mesh_.vertex_handle(isoSurface->viTriangles[i][0]),
                          mesh_.vertex_handle(isoSurface->viTriangles[i][2]),
                          mesh_.vertex_handle(isoSurface->viTriangles[i][1]));
        }
        
        
        std::cout << "Vertices:\t" << mesh_.n_vertices() << std::endl;
        std::cout << "Faces:\t" << mesh_.n_faces() << std::endl;
        
        // Decimation
        
        OpenMesh::Utils::Timer t;
        DecimaterProgMesh decimater(mesh_);
        
        
        ModProgMesh::Handle        modPM;
        ModBalancer::Handle        modB;
        ModNormalFlipping::Handle  modNF;
        
        decimater.add(modPM);
        std::cout << "w/  progressive mesh module\n";
        decimater.add(modB);
        std::cout << "w/  balancer module\n";
        
        decimater.initialize();
        t.start();
        size_t ds = decimater.decimate();
        t.stop();
        std::cout << "decimater counts : " << ds << "\nin time : " << t.as_string()<< std::endl;
        std::string newFileName = replace_extension(this->pmFileName, "pm");
        decimater.module(modPM).write( newFileName );
        decimater.module(modPM);
        size_t s = decimater.module(modPM).infolist().size();
        std::cout<< s<< std::endl;
        this->pmFileName = newFileName;
        loadFromPMFile();
    }
    

}

void
PMLoader::loadFromPMFile()
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

void
PMLoader::enableVolume(){
    useVolume = true;
}

void
PMLoader::disableVolume(){
    useVolume = false;
}

void
PMLoader::setUseVolume(bool useornot){
    useVolume = useornot;
}

