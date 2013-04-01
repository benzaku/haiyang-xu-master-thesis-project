//
//  VDPMLoader.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 1/13/13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//

#include "VDPMLoader.h"
#include <stdio.h>
#include <fstream.h>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/IO/BinaryHelper.hh>
#include <OpenMesh/Core/Utils/Endian.hh>

VDPMLoader::~VDPMLoader(){
    this->qFilename_.clear();
    this->mesh_loaded = false;
    vsplit_loaded.clear();
    vfront_.clear();
    vhierarchy_.clear();
    index2handle_map.clear();
    
    //mesh_.clear();
    
    VDPMMesh::FaceIter fIt(mesh_.faces_begin()), fEnd(mesh_.faces_end());
    
    for(; fIt != fEnd; ++fIt){
        mesh_.delete_face(fIt.handle());
    }
    VDPMMesh::VertexIter vIt(mesh_.vertices_begin()), vEnd(mesh_.vertices_end());
    for(; vIt != vEnd; ++vIt){
        mesh_.delete_vertex(vIt.handle());
    }
    mesh_.garbage_collection();
    if(base_info_data != NULL){
        delete  [] base_info_data;
        base_info_data = NULL;
    }
    base_info_data_size = 0;
    

}

void VDPMLoader::openVDPM_ServerRendering(const char *_filename)
{
    unsigned int                    i;
    unsigned int                    value;
    unsigned int                    fvi[3];
    char                            fileformat[16];
    Vec3f                           p, normal;
    float                           radius, sin_square, mue_square, sigma_square;
    VHierarchyNodeHandleContainer   roots;
    VertexHandle                    vertex_handle;
    VHierarchyNodeIndex             node_index;
    VHierarchyNodeIndex             lchild_node_index, rchild_node_index;
    VHierarchyNodeIndex             fund_lcut_index, fund_rcut_index;
    VHierarchyNodeHandle            node_handle;
    VHierarchyNodeHandle            lchild_node_handle, rchild_node_handle;
    
    
    
    std::ifstream ifs(_filename, std::ios::binary);
    
    if (!ifs)
    {
        std::cerr << "read error\n";
        exit(1);
    }
    
    //
    bool swap = Endian::local() != Endian::LSB;
    
    // read header
    ifs.read(fileformat, 10); fileformat[10] = '\0';
    if (std::string(fileformat) != std::string("VDProgMesh"))
    {
        std::cerr << "Wrong file format.\n";
        ifs.close();
        exit(1);
    }
    
    IO::restore(ifs, n_base_vertices_, swap);
    IO::restore(ifs, n_base_faces_, swap);
    IO::restore(ifs, n_details_, swap);
    
    mesh_.clear();
    vfront_.clear();
    vhierarchy_.clear();
    
    vhierarchy_.set_num_roots(n_base_vertices_);
    
    
    // load base mesh
    for (i=0; i<n_base_vertices_; ++i)
    {
        IO::restore(ifs, p, swap);
        IO::restore(ifs, radius, swap);
        IO::restore(ifs, normal, swap);
        IO::restore(ifs, sin_square, swap);
        IO::restore(ifs, mue_square, swap);
        IO::restore(ifs, sigma_square, swap);
        
        vertex_handle = mesh_.add_vertex(p);
        node_index    = vhierarchy_.generate_node_index(i, 1);
        node_handle   = vhierarchy_.add_node();
        
        VHierarchyNode &node = vhierarchy_.node(node_handle);
        
        node.set_index(node_index);
        node.set_vertex_handle(vertex_handle);
        mesh_.data(vertex_handle).set_vhierarchy_node_handle(node_handle);
        
        node.set_radius(radius);
        node.set_normal(normal);
        node.set_sin_square(sin_square);
        node.set_mue_square(mue_square);
        node.set_sigma_square(sigma_square);
        mesh_.set_normal(vertex_handle, normal);
        
        index2handle_map[node_index] = node_handle;
        roots.push_back(node_handle);
    }
    vfront_.init(roots, n_details_);
    
    for (i=0; i<n_base_faces_; ++i)
    {
        IO::restore(ifs, fvi[0], swap);
        IO::restore(ifs, fvi[1], swap);
        IO::restore(ifs, fvi[2], swap);
        
        mesh_.add_face(mesh_.vertex_handle(fvi[0]),
                       mesh_.vertex_handle(fvi[1]),
                       mesh_.vertex_handle(fvi[2]));
    }
    
    vsplit_loaded.clear();
    
    // load details
    for (i=0; i<n_details_; ++i)
    {
        Vsplit avs;
        // position of v0
        IO::restore(ifs, p, swap);
        
        avs.v0 = p;
        
        // vsplit info.
        IO::restore(ifs, value, swap);
        node_index = VHierarchyNodeIndex(value);
        
        avs.node_index = value;
        
        IO::restore(ifs, value, swap);
        fund_lcut_index = VHierarchyNodeIndex(value);
        
        avs.fund_lcut_index = value;
        
        IO::restore(ifs, value, swap);
        fund_rcut_index = VHierarchyNodeIndex(value);
        
        avs.fund_rcut_index = value;
        
        node_handle = index2handle_map[node_index];
        vhierarchy_.make_children(node_handle);
        
        VHierarchyNode &node   = vhierarchy_.node(node_handle);
        VHierarchyNode &lchild = vhierarchy_.node(node.lchild_handle());
        VHierarchyNode &rchild = vhierarchy_.node(node.rchild_handle());
        
        node.set_fund_lcut(fund_lcut_index);
        node.set_fund_rcut(fund_rcut_index);
        
        vertex_handle = mesh_.add_vertex(p);
        lchild.set_vertex_handle(vertex_handle);
        rchild.set_vertex_handle(node.vertex_handle());
        
        index2handle_map[lchild.node_index()] = node.lchild_handle();
        index2handle_map[rchild.node_index()] = node.rchild_handle();
        
        // view-dependent parameters
        IO::restore(ifs, radius, swap);
        IO::restore(ifs, normal, swap);
        IO::restore(ifs, sin_square, swap);
        IO::restore(ifs, mue_square, swap);
        IO::restore(ifs, sigma_square, swap);
        lchild.set_radius(radius);
        lchild.set_normal(normal);
        lchild.set_sin_square(sin_square);
        lchild.set_mue_square(mue_square);
        lchild.set_sigma_square(sigma_square);
        
        avs.l_radius = radius;
        avs.l_normal = normal;
        avs.l_mue_square = mue_square;
        avs.l_sigma_square = sigma_square;
        avs.l_sin_square = sin_square;
        
        IO::restore(ifs, radius, swap);
        IO::restore(ifs, normal, swap);
        IO::restore(ifs, sin_square, swap);
        IO::restore(ifs, mue_square, swap);
        IO::restore(ifs, sigma_square, swap);
        rchild.set_radius(radius);
        rchild.set_normal(normal);
        rchild.set_sin_square(sin_square);
        rchild.set_mue_square(mue_square);
        rchild.set_sigma_square(sigma_square);
        
        avs.r_radius = radius;
        avs.r_normal = normal;
        avs.r_mue_square = mue_square;
        avs.r_sigma_square = sigma_square;
        avs.r_sin_square = sin_square;
        
        vsplit_loaded.push_back(avs);
        
    }
    
    ifs.close();
    
    //refine 100 vsplits
    int cc = 0;
    for ( vfront_.begin(); !vfront_.end() && cc < 100; ++cc)
    {
        VHierarchyNodeHandle
        node_handle   = vfront_.node_handle();
        
        if (vhierarchy_.is_leaf_node(node_handle) != true)
        {
            force_vsplit(node_handle, vsplits_to_send);
        }
        vfront_.next();
        std::cout << "vfront_ size " << vfront_.size() <<std::endl;
    }
    
    //**********//

    
    // update face and vertex normals
    mesh_.update_face_normals();
    
    // bounding box
    VDPMMesh::ConstVertexIter
    vIt(mesh_.vertices_begin()),
    vEnd(mesh_.vertices_end());
    
    VDPMMesh::Point bbMin, bbMax;
    
    bbMin = bbMax = mesh_.point(vIt);
    for (; vIt!=vEnd; ++vIt)
    {
        bbMin.minimize(mesh_.point(vIt));
        bbMax.maximize(mesh_.point(vIt));
    }
    
    // set center and radius
    VDPMMesh::Point center = 0.5f * (bbMin + bbMax);
    set_scene_pos(0.5f*(bbMin + bbMax), 0.5*(bbMin - bbMax).norm());
    
    
    
    // info
    std::cerr << mesh_.n_vertices() << " vertices, "
    << mesh_.n_edges()    << " edge, "
    << mesh_.n_faces()    << " faces, "
    << n_details_ << " detail vertices\n";
    
    mesh_loaded = true;
}

void
VDPMLoader::openVDPM(const char* _filename)
{
    unsigned int                    i;
    unsigned int                    value;
    unsigned int                    fvi[3];
    char                            fileformat[16];
    Vec3f                           p, normal;
    float                           radius, sin_square, mue_square, sigma_square;
    VHierarchyNodeHandleContainer   roots;
    VertexHandle                    vertex_handle;
    VHierarchyNodeIndex             node_index;
    VHierarchyNodeIndex             lchild_node_index, rchild_node_index;
    VHierarchyNodeIndex             fund_lcut_index, fund_rcut_index;
    VHierarchyNodeHandle            node_handle;
    VHierarchyNodeHandle            lchild_node_handle, rchild_node_handle;
    
    
    
    std::ifstream ifs(_filename, std::ios::binary);
    
    if (!ifs)
    {
        std::cerr << "read error\n";
        exit(1);
    }
    
    //
    bool swap = Endian::local() != Endian::LSB;
    
    // read header
    ifs.read(fileformat, 10); fileformat[10] = '\0';
    if (std::string(fileformat) != std::string("VDProgMesh"))
    {
        std::cerr << "Wrong file format.\n";
        ifs.close();
        exit(1);
    }
    
    IO::restore(ifs, n_base_vertices_, swap);
    IO::restore(ifs, n_base_faces_, swap);
    IO::restore(ifs, n_details_, swap);
    
    mesh_.clear();
    vfront_.clear();
    vhierarchy_.clear();
    
    vhierarchy_.set_num_roots(n_base_vertices_);
    
    
    // load base mesh
    for (i=0; i<n_base_vertices_; ++i)
    {
        IO::restore(ifs, p, swap);
        IO::restore(ifs, radius, swap);
        IO::restore(ifs, normal, swap);
        IO::restore(ifs, sin_square, swap);
        IO::restore(ifs, mue_square, swap);
        IO::restore(ifs, sigma_square, swap);
        
        vertex_handle = mesh_.add_vertex(p);
        node_index    = vhierarchy_.generate_node_index(i, 1);
        node_handle   = vhierarchy_.add_node();
        
        VHierarchyNode &node = vhierarchy_.node(node_handle);
        
        node.set_index(node_index);
        node.set_vertex_handle(vertex_handle);
        mesh_.data(vertex_handle).set_vhierarchy_node_handle(node_handle);
        
        node.set_radius(radius);
        node.set_normal(normal);
        node.set_sin_square(sin_square);
        node.set_mue_square(mue_square);
        node.set_sigma_square(sigma_square);
        mesh_.set_normal(vertex_handle, normal);
        
        index2handle_map[node_index] = node_handle;
        roots.push_back(node_handle);
    }
    vfront_.init(roots, n_details_);
    
    for (i=0; i<n_base_faces_; ++i)
    {
        IO::restore(ifs, fvi[0], swap);
        IO::restore(ifs, fvi[1], swap);
        IO::restore(ifs, fvi[2], swap);
        
        mesh_.add_face(mesh_.vertex_handle(fvi[0]),
                       mesh_.vertex_handle(fvi[1]),
                       mesh_.vertex_handle(fvi[2]));
    }
    
    vsplit_loaded.clear();
    
    // load details
    for (i=0; i<n_details_; ++i)
    {
        Vsplit avs;
        // position of v0
        IO::restore(ifs, p, swap);

        avs.v0 = p;
        
        // vsplit info.
        IO::restore(ifs, value, swap);
        node_index = VHierarchyNodeIndex(value);
        
        avs.node_index = value;
        
        IO::restore(ifs, value, swap);
        fund_lcut_index = VHierarchyNodeIndex(value);
        
        avs.fund_lcut_index = value;
        
        IO::restore(ifs, value, swap);
        fund_rcut_index = VHierarchyNodeIndex(value);
        
        avs.fund_rcut_index = value;
        
        node_handle = index2handle_map[node_index];
        vhierarchy_.make_children(node_handle);
        
        VHierarchyNode &node   = vhierarchy_.node(node_handle);
        VHierarchyNode &lchild = vhierarchy_.node(node.lchild_handle());
        VHierarchyNode &rchild = vhierarchy_.node(node.rchild_handle());
        
        node.set_fund_lcut(fund_lcut_index);
        node.set_fund_rcut(fund_rcut_index);
        
        vertex_handle = mesh_.add_vertex(p);
        lchild.set_vertex_handle(vertex_handle);
        rchild.set_vertex_handle(node.vertex_handle());
        
        index2handle_map[lchild.node_index()] = node.lchild_handle();
        index2handle_map[rchild.node_index()] = node.rchild_handle();
        
        // view-dependent parameters
        IO::restore(ifs, radius, swap);
        IO::restore(ifs, normal, swap);
        IO::restore(ifs, sin_square, swap);
        IO::restore(ifs, mue_square, swap);
        IO::restore(ifs, sigma_square, swap);
        lchild.set_radius(radius);
        lchild.set_normal(normal);
        lchild.set_sin_square(sin_square);
        lchild.set_mue_square(mue_square);
        lchild.set_sigma_square(sigma_square);
        
        avs.l_radius = radius;
        avs.l_normal = normal;
        avs.l_mue_square = mue_square;
        avs.l_sigma_square = sigma_square;
        avs.l_sin_square = sin_square;
        
        IO::restore(ifs, radius, swap);
        IO::restore(ifs, normal, swap);
        IO::restore(ifs, sin_square, swap);
        IO::restore(ifs, mue_square, swap);
        IO::restore(ifs, sigma_square, swap);
        rchild.set_radius(radius);
        rchild.set_normal(normal);
        rchild.set_sin_square(sin_square);
        rchild.set_mue_square(mue_square);
        rchild.set_sigma_square(sigma_square);
        
        avs.r_radius = radius;
        avs.r_normal = normal;
        avs.r_mue_square = mue_square;
        avs.r_sigma_square = sigma_square;
        avs.r_sin_square = sin_square;
        
        vsplit_loaded.push_back(avs);
        
    }
    
    ifs.close();
    
    // update face and vertex normals
    mesh_.update_face_normals();
    
    // bounding box
    VDPMMesh::ConstVertexIter
    vIt(mesh_.vertices_begin()),
    vEnd(mesh_.vertices_end());
    
    VDPMMesh::Point bbMin, bbMax;
    
    bbMin = bbMax = mesh_.point(vIt);
    for (; vIt!=vEnd; ++vIt)
    {
        bbMin.minimize(mesh_.point(vIt));
        bbMax.maximize(mesh_.point(vIt));
    }
    
    // set center and radius
    VDPMMesh::Point center = 0.5f * (bbMin + bbMax);
    
    centroid_radius[0] = center[0];
    centroid_radius[1] = center[1];
    centroid_radius[2] = center[2];
    centroid_radius[3] = 0.5*(bbMin - bbMax).norm();
    set_scene_pos(0.5f*(bbMin + bbMax), 0.5*(bbMin - bbMax).norm());
    
    
    
    // info
    std::cerr << mesh_.n_vertices() << " vertices, "
    << mesh_.n_edges()    << " edge, "
    << mesh_.n_faces()    << " faces, "
    << n_details_ << " detail vertices\n";
    
    mesh_loaded = true;
}


void clear_vsplits_to_send(std::vector<Vsplit*> & splits){
    for (int i = 0; i < splits.size(); i ++) {
        free(splits[i]);
    }
}

void VDPMLoader::rollback_split(data_chunk * vsplitdata)
{
    Vsplit * vsltdata = (Vsplit *)vsplitdata->data;
    int size = vsplitdata->size / VSPLIT_LENGTH;
    std::cout << "Need to roll back " << size << " vsplits" << std::endl;
    VDPMMesh::HalfedgeHandle v0v1;
    for(int i = size - 1; i >= 0; i --){
        Vsplit aVsplit = vsltdata[i];
        //std::cout << "node_index" << aVsplit.node_index << std::endl;
        VHierarchyNodeHandle node_handle = index2handle_map[aVsplit.node_index];
        //std::cout << "rollback node idx = " << node_handle.idx() << std::endl;
        if(ecol_legal(node_handle, v0v1)){
            ecol(node_handle, v0v1);
        } else{
            std::cout << "unable to ecol node : " << node_handle.idx() << std::endl;
        }
    }
    std::cout << "rollback finish! size of vfront " << vfront_.size()<<std::endl;

}

data_chunk* VDPMLoader::adaptive_refinement_server_rendering()
{
    VDPMMesh::HalfedgeHandle v0v1;
    
    float fovy = viewing_parameters_.fovy();
    
    float tolerance_square = viewing_parameters_.tolerance_square();
    float	tan_value = tanf(fovy / 2.0f);
    
    kappa_square_ = 4.0f * tan_value * tan_value * tolerance_square;
    
    split_counter = 0;
    ecol_counter = 0;
    for ( vfront_.begin(); !vfront_.end(); )
    {
        VHierarchyNodeHandle
        node_handle   = vfront_.node_handle(),
        parent_handle = vhierarchy_.parent_handle(node_handle);
        
        
        if (vhierarchy_.is_leaf_node(node_handle) != true &&
            qrefine(node_handle) == true)
        {
            force_vsplit(node_handle);
        }
        
        else if (vhierarchy_.is_root_node(node_handle) != true &&
                 ecol_legal(parent_handle, v0v1) == true       &&
                 qrefine(parent_handle) != true)
        {
            ++ecol_counter;
            ecol(parent_handle, v0v1);
        }
        
        else
        {
            vfront_.next();
        }
        
    }
    
    // free memories tagged as 'deleted'
    mesh_.garbage_collection(false, true, true);
    mesh_.update_face_normals();
    
    _glHandler->update_viewing_parameters(viewing_parameters_);
    
    if (split_counter > 0 || ecol_counter > 0) {
        draw_mesh();
        return _glHandler->getFrameBufferAsJPEGinMen();
    } else{
        data_chunk * returnData = (data_chunk *) malloc(sizeof(data_chunk));
        char * header = "svrender";
        memcpy(returnData->HEADER, header, 8);
        returnData->size = 0;
        returnData->data = NULL;
        return returnData;
    }
    
}

void
VDPMLoader::
draw_mesh()
{
    _glHandler->draw_mesh(mesh_);
}

void
VDPMLoader::
force_vsplit(VHierarchyNodeHandle node_handle)
{
    VDPMMesh::VertexHandle  vl, vr;
    
    get_active_cuts(node_handle, vl, vr);
    
    while (vl == vr)
    {
        force_vsplit(mesh_.data(vl).vhierarchy_node_handle());
        get_active_cuts(node_handle, vl, vr);
    }
    
    vsplit(node_handle, vl, vr);
}

void
VDPMLoader::
vsplit(VHierarchyNodeHandle _node_handle,
       VDPMMesh::VertexHandle vl,
       VDPMMesh::VertexHandle vr)
{
    ++ split_counter;
    
    // refine
    VHierarchyNodeHandle
    lchild_handle = vhierarchy_.lchild_handle(_node_handle),
    rchild_handle = vhierarchy_.rchild_handle(_node_handle);
    
    VDPMMesh::VertexHandle  v0 = vhierarchy_.vertex_handle(lchild_handle);
    VDPMMesh::VertexHandle  v1 = vhierarchy_.vertex_handle(rchild_handle);
    
    mesh_.vertex_split(v0, v1, vl, vr);
    mesh_.set_normal(v0, vhierarchy_.normal(lchild_handle));
    mesh_.set_normal(v1, vhierarchy_.normal(rchild_handle));
    mesh_.data(v0).set_vhierarchy_node_handle(lchild_handle);
    mesh_.data(v1).set_vhierarchy_node_handle(rchild_handle);
    mesh_.status(v0).set_deleted(false);
    mesh_.status(v1).set_deleted(false);
    
    vfront_.remove(_node_handle);
    vfront_.add(lchild_handle);
    vfront_.add(rchild_handle);
}

int count = 0;
data_chunk* VDPMLoader::adaptive_refinement()
{
    VDPMMesh::HalfedgeHandle v0v1;
    
    float fovy = viewing_parameters_.fovy();
    
    float tolerance_square = viewing_parameters_.tolerance_square();
    float	tan_value = tanf(fovy / 2.0f);
    
    kappa_square_ = 4.0f * tan_value * tan_value * tolerance_square;
    
    for ( vfront_.begin(); !vfront_.end(); )
    {
        VHierarchyNodeHandle
        node_handle   = vfront_.node_handle(),
        parent_handle = vhierarchy_.parent_handle(node_handle);
        
        if (vhierarchy_.is_leaf_node(node_handle) != true &&
            qrefine(node_handle) == true)
        {
            force_vsplit(node_handle, vsplits_to_send);
        }
        else
        {
            vfront_.next();
        }
    }
    
    // free memories tagged as 'deleted'
    mesh_.garbage_collection(false, true, true);
    mesh_.update_face_normals();
    
    data_chunk * vsplits_data = (data_chunk *) malloc(sizeof(data_chunk));
    char * h = "vsplitdt";
    strncpy(vsplits_data->HEADER, h, 8);
    vsplits_data->size = 0;
    vsplits_data->size = (int) vsplits_to_send.size() * sizeof(Vsplit);
    vsplits_data->data = (char *) malloc(vsplits_data->size);
    Vsplit * vdata = (Vsplit *)(vsplits_data->data);
    for(int i = 0; i < vsplits_to_send.size(); i ++){
        vdata[i] = *vsplits_to_send[i];
    }
    
    clear_vsplits_to_send(vsplits_to_send);
    vsplits_to_send.clear();
    return vsplits_data;
}

void VDPMLoader::force_vsplit(VHierarchyNodeHandle node_handle, std::vector<Vsplit *>& splits)
{
    VDPMMesh::VertexHandle  vl, vr;
    
    get_active_cuts(node_handle, vl, vr);
    
    while (vl == vr)
    {
        force_vsplit(mesh_.data(vl).vhierarchy_node_handle(), splits);
        get_active_cuts(node_handle, vl, vr);
    }
    vsplit(node_handle, vl, vr, splits);
}

void VDPMLoader::append_vsplit(VHierarchyNodeHandle node_handle, std::vector<Vsplit *>& splits){
    unsigned int          i;
    OpenMesh::Vec3f       pos;
    VHierarchyNodeIndex   node_index, fund_lcut_index, fund_rcut_index;
    float                 lchild_radius, rchild_radius;
    OpenMesh::Vec3f       lchild_normal, rchild_normal;
    float                 lchild_sin_square, rchild_sin_square;
    float                 lchild_mue_square, rchild_mue_square;
    float                 lchild_sigma_square, rchild_sigma_square;
    
    Vsplit *vs = (Vsplit *)malloc(sizeof(Vsplit));
    
    VHierarchyNodeHandle  lchild_handle = vhierarchy_.lchild_handle(node_handle);
    VHierarchyNodeHandle  rchild_handle = vhierarchy_.rchild_handle(node_handle);
    
    VHierarchyNode &node   = vhierarchy_.node(node_handle);
    VHierarchyNode &lchild = vhierarchy_.node(lchild_handle);
    VHierarchyNode &rchild = vhierarchy_.node(rchild_handle);
    
    pos = mesh_.point(lchild.vertex_handle());
    node_index = node.node_index();
    fund_lcut_index = node.fund_lcut_index();
    fund_rcut_index = node.fund_rcut_index();
    lchild_radius = lchild.radius();                rchild_radius = rchild.radius();
    lchild_normal = lchild.normal();                rchild_normal = rchild.normal();
    lchild_sin_square = lchild.sin_square();        rchild_sin_square = rchild.sin_square();
    lchild_mue_square = lchild.mue_square();        rchild_mue_square = rchild.mue_square();
    lchild_sigma_square = lchild.sigma_square();    rchild_sigma_square = rchild.sigma_square();
    
    vs->v0 = pos;
    vs->node_index = node_index.value();
    vs->fund_lcut_index = fund_lcut_index.value();
    vs->fund_rcut_index = fund_rcut_index.value();
    vs->l_radius = lchild_radius;                   vs->r_radius = rchild_radius;
    vs->l_normal = lchild_normal;                   vs->r_normal = rchild_normal;
    vs->l_sin_square = lchild_sin_square;           vs->r_sin_square = rchild_sin_square;
    vs->l_mue_square = lchild_mue_square;           vs->r_mue_square = rchild_mue_square;
    vs->l_sigma_square = lchild_sigma_square;       vs->r_sigma_square = rchild_sigma_square;
    
    splits.push_back(vs);
}

void
VDPMLoader::vsplit(VHierarchyNodeHandle _node_handle,
       VDPMMesh::VertexHandle vl,
       VDPMMesh::VertexHandle vr, std::vector<Vsplit *>& splits)
{
    // refine
    VHierarchyNodeHandle
    lchild_handle = vhierarchy_.lchild_handle(_node_handle),
    rchild_handle = vhierarchy_.rchild_handle(_node_handle);
    VDPMMesh::VertexHandle  v0 = vhierarchy_.vertex_handle(lchild_handle);
    VDPMMesh::VertexHandle  v1 = vhierarchy_.vertex_handle(rchild_handle);
    append_vsplit(_node_handle, splits);
    mesh_.vertex_split(v0, v1, vl, vr);
    mesh_.set_normal(v0, vhierarchy_.normal(lchild_handle));
    mesh_.set_normal(v1, vhierarchy_.normal(rchild_handle));
    mesh_.data(v0).set_vhierarchy_node_handle(lchild_handle);
    mesh_.data(v1).set_vhierarchy_node_handle(rchild_handle);
    mesh_.status(v0).set_deleted(false);
    mesh_.status(v1).set_deleted(false);
    
    vfront_.remove(_node_handle);
    vfront_.add(lchild_handle);
    vfront_.add(rchild_handle);
}

void VDPMLoader::get_active_cuts(const VHierarchyNodeHandle _node_handle,
                     VDPMMesh::VertexHandle &vl, VDPMMesh::VertexHandle &vr)
{
    VDPMMesh::VertexVertexIter  vv_it;
    VHierarchyNodeHandle        nnode_handle;
    
    VHierarchyNodeIndex
    nnode_index,
    fund_lcut_index = vhierarchy_.fund_lcut_index(_node_handle),
    fund_rcut_index = vhierarchy_.fund_rcut_index(_node_handle);
    
    vl = VDPMMesh::InvalidVertexHandle;
    vr = VDPMMesh::InvalidVertexHandle;
    
    for (vv_it=mesh_.vv_iter(vhierarchy_.vertex_handle(_node_handle));
         vv_it; ++vv_it)
    {
        nnode_handle = mesh_.data(vv_it.handle()).vhierarchy_node_handle();
        nnode_index = vhierarchy_.node_index(nnode_handle);
        
        if (vl == VDPMMesh::InvalidVertexHandle &&
            vhierarchy_.is_ancestor(nnode_index, fund_lcut_index) == true)
            vl = vv_it.handle();
        
        if (vr == VDPMMesh::InvalidVertexHandle &&
            vhierarchy_.is_ancestor(nnode_index, fund_rcut_index) == true)
            vr = vv_it.handle();
        
        if (vl != VDPMMesh::InvalidVertexHandle &&
            vr != VDPMMesh::InvalidVertexHandle)
            break;
    }

}

bool VDPMLoader::qrefine(VHierarchyNodeHandle _node_handle){
    VHierarchyNode &node    = vhierarchy_.node(_node_handle);
    Vec3f p       = mesh_.point(node.vertex_handle());
    Vec3f eye_dir = p - viewing_parameters_.eye_pos();;
    
    float	distance = eye_dir.length();
    float	distance2 = distance * distance;
    float	product_value = dot(eye_dir, node.normal());
    
    if (outside_view_frustum(p, node.radius()) == true)
        return	false;
    
    if (oriented_away(node.sin_square(), distance2, product_value) == true)
        return	false;
    
    if (screen_space_error(node.mue_square(),
                           node.sigma_square(),
                           distance2,
                           product_value) == true)
        return false;
    
    return true;

}

bool
VDPMLoader::
ecol_legal(VHierarchyNodeHandle _parent_handle, VDPMMesh::HalfedgeHandle& v0v1)
{
    VHierarchyNodeHandle
    lchild_handle = vhierarchy_.lchild_handle(_parent_handle),
    rchild_handle = vhierarchy_.rchild_handle(_parent_handle);
    
    // test whether lchild & rchild present in the current vfront
    if ( vfront_.is_active(lchild_handle) != true ||
        vfront_.is_active(rchild_handle) != true)
        return  false;
    
    VDPMMesh::VertexHandle v0, v1;
    
    
    v0 = vhierarchy_.vertex_handle(lchild_handle);
    v1 = vhierarchy_.vertex_handle(rchild_handle);
    
    v0v1 = mesh_.find_halfedge(v0, v1);
    
    return  mesh_.is_collapse_ok(v0v1);
}

void
VDPMLoader::
ecol(VHierarchyNodeHandle _node_handle, const VDPMMesh::HalfedgeHandle& v0v1)
{
    VHierarchyNodeHandle
    lchild_handle = vhierarchy_.lchild_handle(_node_handle),
    rchild_handle = vhierarchy_.rchild_handle(_node_handle);
    
    VDPMMesh::VertexHandle  v0 = vhierarchy_.vertex_handle(lchild_handle);
    VDPMMesh::VertexHandle  v1 = vhierarchy_.vertex_handle(rchild_handle);
    
    // coarsen
    mesh_.collapse(v0v1);
    mesh_.set_normal(v1, vhierarchy_.normal(_node_handle));
    
    mesh_.data(v0).set_vhierarchy_node_handle(lchild_handle);
    mesh_.data(v1).set_vhierarchy_node_handle(_node_handle);
    mesh_.status(v0).set_deleted(false);
    mesh_.status(v1).set_deleted(false);
    
    vfront_.add(_node_handle);
    vfront_.remove(lchild_handle);
    vfront_.remove(rchild_handle);
}


bool
VDPMLoader::outside_view_frustum(const OpenMesh::Vec3f &pos, float radius)
{
#if 0
    return
    (frustum_plane_[0].signed_distance(pos) < -radius) ||
    (frustum_plane_[1].signed_distance(pos) < -radius) ||
    (frustum_plane_[2].signed_distance(pos) < -radius) ||
    (frustum_plane_[3].signed_distance(pos) < -radius);
#else
    
    Plane3d   frustum_plane[4];
    
    viewing_parameters_.frustum_planes(frustum_plane);
    
    for (int i = 0; i < 4; i++) {
        if (frustum_plane[i].singed_distance(pos) < -radius)
            return true;
    }
    return false;
#endif
}

bool
VDPMLoader::oriented_away(float sin_square,
                   float distance_square,
                   float product_value)
{
#if 0
    return (product_value > 0)
    &&   ((product_value * product_value) > (distance_square * sin_square));
#else
    if (product_value > 0 &&
        product_value * product_value > distance_square * sin_square)
        return true;
    else
        return false;
#endif
}

bool
VDPMLoader::screen_space_error(float mue_square,
                        float sigma_square,
                        float distance_square,
                        float product_value)
{
#if 0
    float ks_ds = kappa_square_ * distance_square;
    float pv_pv = product_value * product_value;
    return (mue_square >= ks_ds)
    ||   (sigma_square*( distance_square - pv_pv) >= ks_ds*distance_square);
#else
    if ((mue_square >= kappa_square_ * distance_square) ||
        (sigma_square * (distance_square - product_value * product_value) >= kappa_square_ * distance_square * distance_square))
        return	false;
    else
        return	true;
#endif
}

void
VDPMLoader::update_viewing_parameters(double mvmatrix[16], float aspect, float fovy, float tolerance_square)
{
    this->viewing_parameters_.set_modelview_matrix(mvmatrix);
    this->viewing_parameters_.set_aspect(aspect);
    this->viewing_parameters_.set_fovy(fovy);
    this->viewing_parameters_.set_tolerance_square(tolerance_square);
    
    viewing_parameters_.update_viewing_configurations();

}

void
VDPMLoader::set_new_viewing_parameters(ViewingParameters *new_vp)
{
    //this->viewing_parameters_ = *new_vp;
}


void
VDPMLoader::set_scene_pos( const OpenMesh::Vec3f& _cog, float _radius )
{
    
}

int
VDPMLoader::
calculateSPMBaseInfoDataSize()
{
    if(!mesh_loaded)
        return 0;
    
    int size = 3 * sizeof(unsigned int); //n_base_vertices_, n_base_faces_, n_details_
    
    int sizeofavetexpackage = 4 * sizeof(float) + 2 * sizeof(Vec3f);
    
    size = size + n_base_vertices_ * sizeofavetexpackage;
    
    int sizeofafaceidxpackage = 3 * sizeof(unsigned int);
    
    size = size + n_base_faces_ * sizeofafaceidxpackage;
    
    //add size of centroid radius array
    size += 4 * sizeof(float);
    
    base_info_data_size = size;
    
    return size;
}

char *
VDPMLoader::get_base_info_data()
{
    if(base_info_data == NULL && base_info_data_size > 0){
        //generate base info data
        base_info_data = new char[base_info_data_size];
        std::ifstream ifs(qFilename_.c_str(), std::ios::binary);
        
        if (!ifs)
        {
            std::cerr << "read error\n";
            exit(1);
        }
        
        //
        bool swap = Endian::local() != Endian::LSB;
        
        char fileformat[16];
        
        // read header
        ifs.read(fileformat, 10); fileformat[10] = '\0';
        if (std::string(fileformat) != std::string("VDProgMesh"))
        {
            std::cerr << "Wrong file format.\n";
            ifs.close();
            exit(1);
        }
        
        ifs.read(base_info_data, base_info_data_size - 4 * sizeof(float));
        ifs.close();
    }
    
    memcpy(&base_info_data[base_info_data_size - 4 * sizeof(float)], centroid_radius, 4 * sizeof(float));
    
    return base_info_data;
}

void
VDPMLoader::generateRoughMesh()
{
    std::cout << "vfront before: " << vfront_.size() << std::endl;
    //generate rough mesh to send
    std::vector<Vsplit*> templist;
    for ( vfront_.begin(); !vfront_.end(); )
    {
        VHierarchyNodeHandle
        node_handle   = vfront_.node_handle();
        force_vsplit(node_handle, templist);
        vfront_.next();
    }
    
    // free memories tagged as 'deleted'
    //mesh_.garbage_collection(false, true, true);
    mesh_.update_face_normals();
    std::cout << "vfront after: " << vfront_.size() << std::endl;
}



