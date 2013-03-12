//
//  VDPMLoader.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 1/13/13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__VDPMLoader__
#define __MeshStreamingServer__VDPMLoader__



#include <iostream>
#include <string>
#include <vector>

#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>

#include <OpenMesh/Tools/VDPM/MeshTraits.hh>
#include <OpenMesh/Tools/VDPM/StreamingDef.hh>
#include <OpenMesh/Tools/VDPM/ViewingParameters.hh>
#include <OpenMesh/Tools/VDPM/VHierarchy.hh>
#include <OpenMesh/Tools/VDPM/VFront.hh>
#include "PublicIncludes.h"


using namespace OpenMesh;
using namespace OpenMesh::VDPM;

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

class VDPMLoader
{
public:
    
    VDPMLoader(){
        mesh_loaded = false;
    };
    
    VDPMLoader(std::string &filename){
        qFilename_ = filename;
        mesh_loaded = false;
        base_info_data_size = 0;
        base_info_data = NULL;
    };
    
    ~VDPMLoader();
    
    void openVDPM(const char* _filename);
    
    void loadVDPM(){
        openVDPM(qFilename_.c_str());
    }
    
    ////
    bool isMeshLoaded(){
        return mesh_loaded;
    };
    
    int  calculateSPMBaseInfoDataSize();
    
    int  get_base_info_data_size(){
        return base_info_data_size;
    };
    
    char * get_base_info_data();
    void set_new_viewing_parameters(ViewingParameters *new_vp);
    
    void update_viewing_parameters(double mvmatrix[16], float aspect, float fovy, float tolerance_square);
    
    data_chunk* adaptive_refinement();
    
    std::vector<Vsplit>* get_vsplit_loaded(){ return &vsplit_loaded;};


private:
    
    std::string         qFilename_;
    VHierarchy          vhierarchy_;
    VFront              vfront_;
    ViewingParameters   viewing_parameters_;
    float               kappa_square_;
    bool                adaptive_mode_;
    
    unsigned int        n_base_vertices_;
    unsigned int        n_base_edges_;
    unsigned int        n_base_faces_;
    unsigned int        n_details_;
    
    VDPMMesh            mesh_;
    
    bool                mesh_loaded;
    
    int                 base_info_data_size;
    
    char *              base_info_data;
    
    std::vector<Vsplit*> vsplits_to_send;
    
    std::vector<Vsplit> vsplit_loaded;
    
    std::map<VHierarchyNodeIndex, VHierarchyNodeHandle> index2handle_map;

private:
    
    bool outside_view_frustum(const OpenMesh::Vec3f &pos, float radius);
    
    bool oriented_away(float sin_square,
                       float distance_square,
                       float product_value);
    
    bool screen_space_error(float mue_square,
                            float sigma_square,
                            float distance_square,
                            float product_value);
    
    void update_viewing_parameters();
    
    
    void set_scene_pos( const OpenMesh::Vec3f& _cog, float _radius );
    
    bool qrefine(VHierarchyNodeHandle _node_handle);
    
    void force_vsplit(VHierarchyNodeHandle node_handle, std::vector<Vsplit *>& splits);
    
    void get_active_cuts(const VHierarchyNodeHandle _node_handle,
                         VDPMMesh::VertexHandle &vl, VDPMMesh::VertexHandle &vr);

    void vsplit(VHierarchyNodeHandle _node_handle,
                       VDPMMesh::VertexHandle vl,
                VDPMMesh::VertexHandle vr, std::vector<Vsplit *>& splits);
    
    data_chunk* convert_vsplit_list_to_data_chunk();
    
    void append_vsplit(VHierarchyNodeHandle node_handle, std::vector<Vsplit *>& splits);

};

#endif /* defined(__MeshStreamingServer__VDPMLoader__) */
