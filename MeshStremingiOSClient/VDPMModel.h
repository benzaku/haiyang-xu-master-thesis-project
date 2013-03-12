//
//  VDPMModel.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/14/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "ProgMeshModel.h"
#import "MeshObj.h"
#import <GLKit/GLKit.h>

#include "AdditionalIncludes.h"



struct viewparam {
    double      modelViewMatrix[16];
    float       aspect;
    float       fovy;
    float       tolerance_square;
};

@interface VDPMModel : ProgMeshModel{
    MeshObj * _mesh;
    
    int _baseMeshInfoDataSize;
    
    unsigned int        _n_base_vertices_;
    unsigned int        _n_base_faces_;
    unsigned int        _n_details_;
    
    VHierarchy          vhierarchy_;
    VFront              vfront_;
    ViewingParameters   viewing_parameters_;
    float               kappa_square_;
    bool                adaptive_mode_;
    
    VDPMMesh            mesh_;
    
    bool                base_mesh_loaded_flag;
    
    std::map<VHierarchyNodeIndex, VHierarchyNodeHandle> index2handle_map;
    
    UpdatePartIndex updatePartIndex;
    UpdatePartIndex indicePartIndex;
    UpdateInfo updateInfo;

    VDPMMesh::Point BBMAX, BBMIN;
}



@property (strong, atomic) MeshObj *mesh;
@property (atomic, assign) unsigned int n_base_vertices;
@property (atomic, assign) unsigned int n_base_faces;
@property (atomic, assign) unsigned int n_details;
@property (nonatomic, assign) ViewingParameters viewingParams;

- (void) update_viewing_parameters: (GLKMatrix4) _modelview_matrix  :(float) aspect: (float) fovy;

- (bool) qrefine: (VHierarchyNodeHandle)_node_handle;

- (bool) outside_view_frustum:(const Vec3f&) pos: (float) radius;

- (bool) oriented_away:(float) sin_square: (float) distance_square: (float) product_value;

- (bool) screen_space_error:(float) mue_square : (float) sigma_square :
                   (float) distance_square : (float) product_value;

- (UpdateInfo *) update_mesh_with_vsplits:(NSData *) vsplits_data;

- (void) decrease_tolerance_square;

- (void) set_tolerance_square : (float) tsq;

- (void) adaptive_refinement;

- (bool) get_require_n_refinement;

- (NSData *) getViewingParameters;

- (VDPMMesh *) getMesh;


@end
