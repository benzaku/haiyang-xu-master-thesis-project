/*
 * qrefine
 * input: vertex handle in the vertex hierarchy
 * return: if the input vertex need to split? 
 */
bool VDPMLoader::qrefine(VHierarchyNodeHandle _node_handle){
    VHierarchyNode &node    = vhierarchy_.node(_node_handle);
    Vec3f p       			= mesh_.point(node.vertex_handle());
    Vec3f eye_dir 			= p - viewing_parameters_.eye_pos();
    
    float	distance 		= eye_dir.length();
    float	distance2 		= distance * distance;
    float	product_value 	= dot(eye_dir, node.normal());
    
    //if vertex is out of view frustum?
    if (outside_view_frustum(p, node.radius()) == true)
        return	false;

    //if vertex normal direction is out of view scope?
    if (oriented_away(node.sin_square(), distance2, product_value) == true)
        return	false;

    //if current screen error is under tolerance?
    if (screen_space_error(node.mue_square(),
                           node.sigma_square(),
                           distance2,
                           product_value) == true)
        return false;
    
    return true;

}
