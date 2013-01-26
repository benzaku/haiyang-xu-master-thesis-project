//
//  VDPMModel.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/14/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//


#import "VDPMModel.h"
#import "Constants.h"

#include <vector>


@implementation VDPMModel


- (void) loadBaseMeshInfo:(NSData *)baseMeshInfoData
{
    NSLog(@"Loading Mesh : %@", _name);
    unsigned int                    fvi[3];
    Vec3f                           p, normal;
    float                           radius, sin_square, mue_square, sigma_square;
    VHierarchyNodeHandleContainer   roots;
    VertexHandle                    vertex_handle;
    VHierarchyNodeIndex             node_index;
    VHierarchyNodeHandle            node_handle;
    
    
    _baseMeshInfoDataSize = [baseMeshInfoData length];
    
    char buffer[_baseMeshInfoDataSize];
    
    [baseMeshInfoData getBytes:buffer length:_baseMeshInfoDataSize];
    
    membuf sbuf(buffer, buffer + sizeof(buffer));
    std::istream ifs(&sbuf);
    
    ifs.read((char *)&_n_base_vertices_, sizeof(_n_base_vertices_));
    ifs.read((char *)&_n_base_faces_, sizeof(_n_base_faces_));
    ifs.read((char *)&_n_details_, sizeof(_n_details_));
    
    mesh_.clear();
    vfront_.clear();
    vhierarchy_.clear();
    
    vhierarchy_.set_num_roots(_n_base_vertices_);
    
    // load base mesh
    for (int i=0; i<_n_base_vertices_; ++i)
    {
        ifs.read((char *)&p, sizeof(p));
        ifs.read((char *)&radius, sizeof(radius));
        ifs.read((char *)&normal, sizeof(normal));
        ifs.read((char *)&sin_square, sizeof(sin_square));
        ifs.read((char *)&mue_square, sizeof(mue_square));
        ifs.read((char *)&sigma_square, sizeof(sigma_square));
        
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
    vfront_.init(roots, _n_details_);
    for (int i=0; i<_n_base_faces_; ++i)
    {
        ifs.read((char *)fvi, 3 * sizeof(unsigned int));
        
        mesh_.add_face(mesh_.vertex_handle(fvi[0]),
                       mesh_.vertex_handle(fvi[1]),
                       mesh_.vertex_handle(fvi[2]));
    }
    
    //mesh_.update_vertex_normals();
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
    VDPMMesh::Point cen = 0.5f*(bbMin + bbMax);
    centroid_radius[0] = cen.data()[0];
    centroid_radius[1] = cen.data()[1];
    centroid_radius[2] = cen.data()[2];
    
    centroid_radius[3] = 0.5*(bbMin - bbMax).norm();
    
    base_mesh_loaded_flag = true;
    
    NSLog(@"Base Mesh Load Finished!");
    NSLog(@"%d vertices, %d faces %d details", _n_base_vertices_, _n_base_faces_, _n_details_);
    
}

- (id) initWithModelObject:(ModelObj *)modelObj
{
    [self init];
    _mesh = (MeshObj *)modelObj;
    _name = modelObj.ObjectFileName;
    _type = modelObj.ModelType;
    
    updateInfo.~pair();
    
    return self;
}

- (GLfloat *) getBaseMeshVertexNormalArray
{
    if (BASE_MESH_VERTEX_NORMAL_ARRAY == NULL) {
        [self generateBaseMeshVertexNormalArray];
    }
    
    return BASE_MESH_VERTEX_NORMAL_ARRAY;
}

- (GLsizei) getBaseMeshVertexNormalArraySize
{
    
    return BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE;
}

- (GLsizei) getTotalVertexNormalArraySize
{
    if(TOTAL_VERTEX_NORMAL_ARRAY_SIZE == 0){
        TOTAL_VERTEX_NORMAL_ARRAY_SIZE = (_n_base_vertices_ + _n_details_) * 3 * 2;
    }
    
    return TOTAL_VERTEX_NORMAL_ARRAY_SIZE;
}

- (void) generateBaseMeshVertexNormalArray
{
    if(BASE_MESH_VERTEX_NORMAL_ARRAY != NULL){
        delete [] BASE_MESH_VERTEX_NORMAL_ARRAY;
        BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 0;
    }
    BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 2 * _n_base_vertices_ * 3;
    
    BASE_MESH_VERTEX_NORMAL_ARRAY = new GLfloat[[self getTotalVertexNormalArraySize]];
    for(int i = 0; i < [self getTotalVertexNormalArraySize]; i ++)
        BASE_MESH_VERTEX_NORMAL_ARRAY[i] = 0.0f;

    VDPMMesh::VertexHandle vh;
    VDPMMesh::Normal vn;
    VDPMMesh::Point p;
    
    VDPMMesh::VertexIter v_it, v_end(mesh_.vertices_end());
    
    for(v_it = mesh_.vertices_begin(); v_it!= v_end; ++v_it){
        p = mesh_.point(v_it);
        vn = mesh_.normal(v_it);
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[v_it.handle().idx() * 2 * 3]), &(p.values_[0]), 3 * sizeof(float));
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[v_it.handle().idx() * 2 * 3 + 3]), &(vn.values_[0]), 3 * sizeof(float));
        
        //update current vertex idx
        currentVerticeIdx = v_it.handle().idx();
        nCurrentVertices ++;
    }
    currentVerticeIdx ++;
    
}

- (unsigned int *) getMeshIndiceArray
{
    if (MESH_INDICE_ARRAY == NULL) {
        [self generateInitMeshIndiceArray];
    }
    return MESH_INDICE_ARRAY;
    
}

- (GLsizei) getTotalFaceIndiceBufferSize
{
    if (TOTAL_FACE_INDICE_BUFFER_SIZE == 0) {
        TOTAL_FACE_INDICE_BUFFER_SIZE = (_n_base_faces_ + 2 * _n_details_) * 3 * sizeof(unsigned int);
    }
    
    return TOTAL_FACE_INDICE_BUFFER_SIZE;
}

- (void) generateInitMeshIndiceArray
{
    if (MESH_INDICE_ARRAY != NULL) {
        delete [] MESH_INDICE_ARRAY;
        MESH_INDICE_ARRAY_SIZE = 0;
    }
    
    MESH_INDICE_ARRAY_SIZE = 3 * (_n_base_faces_ + 2 * _n_details_) ;
    MESH_INDICE_ARRAY = new unsigned int[MESH_INDICE_ARRAY_SIZE];
    
    VDPMMesh::ConstFaceIter   fIt(mesh_.faces_begin()), fEnd(mesh_.faces_end());
    VDPMMesh::ConstFaceVertexIter     fvIt;
    
    
    int cnt = 0;
    
    unsigned int * p_indice = (unsigned int *)&(MESH_INDICE_ARRAY[0]);
    
    for(; fIt != fEnd; ++fIt){
        fvIt = mesh_.cfv_iter(fIt.handle());
        for(int i = 0; i < 3; i ++){
            *p_indice = (fvIt.handle()).idx();
            ++ p_indice;
            ++fvIt;
            ++cnt;
        }
        
    }
    
    currentRecoveredFaceNumber = _n_base_faces_;
    
}

- (GLsizei) getBaseMeshIndiceBufferSize
{
    if (BASE_MESH_INDICE_BUFFER_SIZE == 0) {
        BASE_MESH_INDICE_BUFFER_SIZE = _n_base_faces_ * 3 * sizeof(unsigned int);
    }
    
    return BASE_MESH_INDICE_BUFFER_SIZE;
}

- (void) adaptive_refinement
{
    VDPMMesh::HalfedgeHandle v0v1;
    
    float fovy = viewing_parameters_.fovy();
    float tolerance_square = viewing_parameters_.tolerance_square();
    float tan_value = tanf(fovy / 2.0f);
    
    kappa_square_ = 4.0f * tan_value * tan_value * tolerance_square;
    int vfront_count = 0;
    for( vfront_.begin(); !vfront_.end();){
        VHierarchyNodeHandle node_handle = vfront_.node_handle(), parent_handle = vhierarchy_.parent_handle(node_handle);
        if(vhierarchy_.is_leaf_node(node_handle) != true && [self qrefine:node_handle] == true){
            NSLog(@"Need to force_vsplit %d", node_handle.idx());
            
        }
        vfront_.next();
        //else if (vhierarchy_.is_root_node(node_handle) != true) &&
        
    }
}

- (void) update_viewing_parameters: (GLKMatrix4) _modelview_matrix  :(float) aspect: (float) fovy
{
    viewing_parameters_.set_modelview_matrix((double *)_modelview_matrix.m);
    viewing_parameters_.set_aspect(aspect);
    viewing_parameters_.set_fovy(fovy);
    
    viewing_parameters_.update_viewing_configurations();

}

- (NSData *) getViewingParameters
{
    viewparam aVP;
    viewing_parameters_.get_modelview_matrix(aVP.modelViewMatrix);
    aVP.aspect = viewing_parameters_.aspect();
    aVP.fovy = viewing_parameters_.fovy();
    aVP.tolerance_square = viewing_parameters_.tolerance_square();
    
    NSLog(@"fovy : %f tor : %f",aVP.fovy, aVP.tolerance_square );
    int command_size = [COMMAND_SYNC_SPM_VIEWING_PARAMS length];
    int vp_size = sizeof(viewparam);
    char request[command_size + vp_size];    
    strcpy(request, [COMMAND_SYNC_SPM_VIEWING_PARAMS cStringUsingEncoding:NSUTF8StringEncoding]);
    
    memcpy(&request[command_size], &aVP, vp_size);
    
    return [[NSData alloc] initWithBytes: request length:command_size + vp_size];
    
}

- (bool) qrefine: (VHierarchyNodeHandle)_node_handle
{
    VHierarchyNode &node    = vhierarchy_.node(_node_handle);
    Vec3f p       = mesh_.point(node.vertex_handle());
    Vec3f eye_dir = p - viewing_parameters_.eye_pos();;
    
    float	distance = eye_dir.length();
    float	distance2 = distance * distance;
    float	product_value = dot(eye_dir, node.normal());
    
    if ([self outside_view_frustum: p : node.radius()] == true)
        return	false;
    
    if ([self oriented_away: node.sin_square() : distance2 : product_value] == true)
        return	false;
    
    if ([self screen_space_error:node.mue_square(): node.sigma_square(): distance2: product_value] == true)
        return false;
    
    return true;
}

- (bool) outside_view_frustum:(const Vec3f&) pos: (float) radius
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

- (bool) oriented_away:(float) sin_square: (float) distance_square: (float) product_value
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

- (bool) screen_space_error:(float) mue_square : (float) sigma_square : (float) distance_square : (float) product_value
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

- (UpdateInfo *) update_mesh_with_vsplits:(NSData *) vsplits_data
{
    
    Vec3f                           p, normal;
    VHierarchyNodeHandleContainer   roots;
    VertexHandle                    vertex_handle;
    VHierarchyNodeIndex             node_index;
    VHierarchyNodeIndex             lchild_node_index, rchild_node_index;
    VHierarchyNodeIndex             fund_lcut_index, fund_rcut_index;
    VHierarchyNodeHandle            node_handle;
    VHierarchyNodeHandle            lchild_node_handle, rchild_node_handle;
    
    int n_split = vsplits_data.length / sizeof(Vsplit);

    Vsplit * splits = new Vsplit[n_split];
    [vsplits_data getBytes:splits length:vsplits_data.length];
    std::cout << splits[0].l_normal << std::endl;
    
    for(int i = 0; i < n_split; i ++){
        Vsplit asplit = splits[i];
        
        //[self printVsplit:asplit];
        
        OpenMesh::VertexHandle  vertex_handle;
        VHierarchyNodeHandle    node_handle, lchild_handle, rchild_handle;
        
        VHierarchyNodeIndex _node_index = VHierarchyNodeIndex(asplit.node_index);
        VHierarchyNodeIndex _fund_lcut_index = VHierarchyNodeIndex(asplit.fund_lcut_index);
        VHierarchyNodeIndex _fund_rcut_index = VHierarchyNodeIndex(asplit.fund_rcut_index);
        
        node_handle = vhierarchy_.node_handle(_node_index);
        vhierarchy_.make_children(node_handle);
        
        
        lchild_handle = vhierarchy_.lchild_handle(node_handle);
        rchild_handle = vhierarchy_.rchild_handle(node_handle);
        
        vhierarchy_.node(node_handle).set_fund_lcut(_fund_lcut_index);
        vhierarchy_.node(node_handle).set_fund_rcut(_fund_rcut_index);
        
        vertex_handle = mesh_.add_vertex(asplit.v0);
        vhierarchy_.node(lchild_handle).set_vertex_handle(vertex_handle);
        vhierarchy_.node(rchild_handle).set_vertex_handle(vhierarchy_.node(node_handle).vertex_handle());
        
        vhierarchy_.node(lchild_handle).set_radius(asplit.l_radius);
        vhierarchy_.node(lchild_handle).set_normal(asplit.l_normal);
        vhierarchy_.node(lchild_handle).set_sin_square(asplit.l_sin_square);
        vhierarchy_.node(lchild_handle).set_mue_square(asplit.l_mue_square);
        vhierarchy_.node(lchild_handle).set_sigma_square(asplit.l_sigma_square);
        
        vhierarchy_.node(rchild_handle).set_radius(asplit.r_radius);
        vhierarchy_.node(rchild_handle).set_normal(asplit.r_normal);
        vhierarchy_.node(rchild_handle).set_sin_square(asplit.r_sin_square);
        vhierarchy_.node(rchild_handle).set_mue_square(asplit.r_mue_square);
        vhierarchy_.node(rchild_handle).set_sigma_square(asplit.r_sigma_square);
    }
    
    [self refine];
    return &updateInfo;
}

- (void) printVsplit:(Vsplit) vsplit
{
    std::cout << vsplit.v0 << std::endl;
    std::cout << vsplit.l_normal << std::endl;
    std::cout << vsplit.r_normal << std::endl;
    
}

- (void) refine
{
    
    VDPMMesh::HalfedgeHandle v0v1;
    
    updatePartIndex.clear();
    indicePartIndex.clear();
    updateInfo.~pair();
    
    float fovy = viewing_parameters_.fovy();
    
    float tolerance_square = viewing_parameters_.tolerance_square();
    float	tan_value = tanf(fovy / 2.0f);
    
    kappa_square_ = 4.0f * tan_value * tan_value * tolerance_square;
    
    //assert( !vfront_.end() );
    int vfront_count = 0;
    for ( vfront_.begin(); !vfront_.end(); )
    {
        VHierarchyNodeHandle
        node_handle   = vfront_.node_handle(),
        parent_handle = vhierarchy_.parent_handle(node_handle);
        
        if (vhierarchy_.is_leaf_node(node_handle) != true &&
            [self qrefine:node_handle] == true)
        {
            [self force_vsplit:node_handle];
        }
        else
        {
            vfront_.next();
            vfront_count ++;
        }
    }
    
    NSLog(@"size of vfront : %d", vfront_count);
    // free memories tagged as 'deleted'
    mesh_.garbage_collection(false, true, true);
    mesh_.update_face_normals();
    //updateInfo = std::make_pair(&updatePartIndex, &indicePartIndex);
}

- (void) force_vsplit: (VHierarchyNodeHandle) node_handle
{
    VDPMMesh::VertexHandle  vl, vr;
    
    [self get_active_cuts:node_handle: vl: vr];
    
    while (vl == vr )
    {
        [self force_vsplit:mesh_.data(vl).vhierarchy_node_handle()];
        [self get_active_cuts:node_handle: vl: vr];
    }
    
    [self vsplit:node_handle: vl: vr];
}

- (void) vsplit: (VHierarchyNodeHandle) _node_handle: (VDPMMesh::VertexHandle) vl:(VDPMMesh::VertexHandle) vr
{
    // refine
    VHierarchyNodeHandle
    lchild_handle = vhierarchy_.lchild_handle(_node_handle),
    rchild_handle = vhierarchy_.rchild_handle(_node_handle);
    
    VDPMMesh::VertexHandle  v0 = vhierarchy_.vertex_handle(lchild_handle);
    VDPMMesh::VertexHandle  v1 = vhierarchy_.vertex_handle(rchild_handle);
    
    int nv11 = 0;
    for (VDPMMesh::VertexFaceIter vfiter = mesh_.vf_begin(v1); vfiter != mesh_.vf_end(v1); ++ vfiter) {
        nv11 ++;
    }
    
    
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
    //[self updateVetexNormalArray:nv11 :v0 :v1];
}

- (void) updateVetexNormalArray :   (int) nv11
:(VDPMMesh::VertexHandle) v0 : (VDPMMesh::VertexHandle) v1
{
    int idx;
    int nv0 = 0, nv1 = 0;
    memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[nCurrentVertices * 3 * 2]), mesh_.point(v0).data(), 3 * sizeof(float));
    updatePartIndex.insert(nCurrentVertices * 3 * 2);
    
    nCurrentVertices ++;
    currentVerticeIdx ++;
    //currentRecoveredFaceNumber += 2;
    /*
    BBMAX.maximize(pminfo->p0);
    BBMIN.minimize(pminfo->p0);
    center = 0.5f*(BBMAX + BBMIN);
    radius = 0.5*(BBMIN - BBMAX).norm();
     */
    //updating affected face normals and vertex normals
    // face normals
    for (VDPMMesh::VertexFaceIter vfiter = mesh_.vf_begin(v0); vfiter != mesh_.vf_end(v0); ++ vfiter) {
        mesh_.update_normal(vfiter.handle());
        
        nv0 ++;
        // update indice
        VDPMMesh::ConstFaceVertexIter cfviter = mesh_.cfv_iter(vfiter.handle());
        
        idx = cfviter.handle().idx();
        MESH_INDICE_ARRAY[vfiter.handle().idx() * 3] = idx;
        indicePartIndex.insert(vfiter.handle().idx() * 3);
        ++cfviter;
        idx = cfviter.handle().idx();
        MESH_INDICE_ARRAY[vfiter.handle().idx() * 3 + 1] = idx;
        indicePartIndex.insert(vfiter.handle().idx() * 3 + 1);
        ++cfviter;
        idx = cfviter.handle().idx();
        MESH_INDICE_ARRAY[vfiter.handle().idx() * 3 + 2] = idx;
        indicePartIndex.insert(vfiter.handle().idx() * 3 + 2);
        
    }
    for (VDPMMesh::VertexFaceIter vfiter = mesh_.vf_begin(v1); vfiter != mesh_.vf_end(v1); ++ vfiter) {
        mesh_.update_normal(vfiter.handle());
        nv1 ++;
    }
    
    currentRecoveredFaceNumber += ((nv1 + nv0 - nv11) / 2);
    for (VDPMMesh::VertexVertexIter vviter = mesh_.vv_begin(v0); vviter != mesh_.vv_end(v0); ++ vviter) {
        mesh_.update_normal(vviter.handle());
        // update normal in vertex normal array
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[vviter.handle().idx() * 3 * 2 + 3]), mesh_.normal(vviter.handle()).data(), 3 * sizeof(float));
        
        updatePartIndex.insert(vviter.handle().idx() * 3 * 2 + 3);
    }
    
    for (VDPMMesh::VertexVertexIter vviter = mesh_.vv_begin(v1); vviter != mesh_.vv_end(v1); ++ vviter) {
        mesh_.update_normal(vviter.handle());
        mesh_.update_normal(vviter.handle());
        // update normal in vertex normal array
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[vviter.handle().idx() * 3 * 2 + 3]), mesh_.normal(vviter.handle()).data(), 3 * sizeof(float));
        
        updatePartIndex.insert(vviter.handle().idx() * 3 * 2 + 3);
    }
    
    
}

- (void) get_active_cuts: (const VHierarchyNodeHandle) _node_handle : (VDPMMesh::VertexHandle &)vl:(VDPMMesh::VertexHandle &)vr
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
        
        /*if (vl == VDPMMesh::InvalidVertexHandle && nnode_index.is_ancestor_index(fund_lcut_index) == true)
         vl = vv_it.handle();
         if (vr == VDPMMesh::InvalidVertexHandle && nnode_index.is_ancestor_index(fund_rcut_index) == true)
         vr = vv_it.handle();*/
        
        if (vl != VDPMMesh::InvalidVertexHandle &&
            vr != VDPMMesh::InvalidVertexHandle)
            break;
    }

}

@synthesize mesh = _mesh;
@synthesize n_base_vertices = _n_base_vertices_;
@synthesize n_base_faces = _n_base_faces_;
@synthesize n_details = _n_details_;
@synthesize viewingParams = viewing_parameters_;
@end
