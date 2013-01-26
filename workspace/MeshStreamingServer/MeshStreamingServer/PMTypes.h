//
//  PMTypes.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 11/6/12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#ifndef MeshStreamingServer_PMTypes_h
#define MeshStreamingServer_PMTypes_h

#include <OpenMesh/Core/Mesh/Attributes.hh>
#include <OpenMesh/Core/IO/BinaryHelper.hh>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>

#include <OpenMesh/Tools/Decimater/DecimaterT.hh>
#include <OpenMesh/Tools/Decimater/ModQuadricT.hh>
#include <OpenMesh/Tools/Decimater/ModBaseT.hh>
#include <OpenMesh/Tools/Decimater/ModNormalFlippingT.hh>
#include <OpenMesh/Tools/Decimater/ModProgMeshT.hh>
#include <OpenMesh/Tools/Decimater/ModIndependentSetsT.hh>
#include <OpenMesh/Tools/Utils/Timer.hh>

using namespace OpenMesh;
using namespace OpenMesh::Attributes;
using namespace OpenMesh::Decimater;



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


typedef OpenMesh::Decimater::DecimaterT<MyMesh> DecimaterProgMesh;
typedef OpenMesh::Decimater::ModNormalFlippingT<MyMesh>  ModNormalFlipping;
typedef OpenMesh::Decimater::ModQuadricT<MyMesh>         ModQuadric;
typedef OpenMesh::Decimater::ModProgMeshT<MyMesh>        ModProgMesh;
typedef OpenMesh::Decimater::ModIndependentSetsT<MyMesh> ModIndependentSets;



template <class D>
class ModBalancerT : public OpenMesh::Decimater::ModQuadricT<D>
{
public:
    
    typedef OpenMesh::Decimater::ModQuadricT<D> BaseModQ;
    
    DECIMATING_MODULE( ModBalancerT, D, Balancer );
    
public:
    
    typedef size_t level_t;
    
public:
    
    /// Constructor
    ModBalancerT( D &_dec )
    : BaseModQ( _dec ),
    max_level_(0), n_vertices_(0)
    {
        BaseModQ::mesh().add_property( level_ );
    }
    
    
    /// Destructor
    virtual ~ModBalancerT()
    {
        BaseModQ::mesh().remove_property( level_ );
    }
    
public:
    
    static level_t calc_bits_for_roots( size_t _n_vertices )
    {
        return level_t(std::ceil(std::log((double)_n_vertices)*inv_log2_));
    }
    
public: // inherited
    
    void initialize(void)
    {
        BaseModQ::initialize();
        n_vertices_ = BaseModQ::mesh().n_vertices();
        n_roots_    = calc_bits_for_roots(n_vertices_);
    }
    
    virtual float collapse_priority(const CollapseInfo& _ci)
    {
        level_t newlevel = std::max( BaseModQ::mesh().property( level_, _ci.v0 ),
                                    BaseModQ::mesh().property( level_, _ci.v1 ) )+1;
        level_t newroots = calc_bits_for_roots(n_vertices_-1);
        
        if ( (newroots + newlevel) < 32 )
        {
            double err = BaseModQ::collapse_priority( _ci );
            
            if (err!=BaseModQ::ILLEGAL_COLLAPSE)
            {
                return float(newlevel + err/(err+1.0));
            }
            
            
        }
        return BaseModQ::ILLEGAL_COLLAPSE;
    }
    
    /// post-process halfedge collapse (accumulate quadrics)
    void postprocess_collapse(const CollapseInfo& _ci)
    {
        BaseModQ::postprocess_collapse( _ci );
        
        BaseModQ::mesh().property( level_, _ci.v1 ) =
        std::max( BaseModQ::mesh().property( level_, _ci.v0 ),
                 BaseModQ::mesh().property( level_, _ci.v1 ) ) + 1;
        
        max_level_ = std::max( BaseModQ::mesh().property( level_, _ci.v1 ), max_level_ );
        n_roots_   = calc_bits_for_roots(--n_vertices_);
    }
    
public:
    
    level_t max_level(void) const       { return max_level_; }
    level_t bits_for_roots(void) const  { return n_roots_; }
    
private:
    
    /// hide this method
    void set_binary(bool _b) {}
    
    OpenMesh::VPropHandleT<level_t> level_;
    
    level_t max_level_; // maximum level reached
    level_t n_roots_;   // minimum bits for root nodes
    size_t  n_vertices_;// number of potential root nodes
    
    static const double inv_log2_;
    
};

template <typename D>
const double ModBalancerT<D>::inv_log2_ = 1.0/std::log(2.0);

typedef ModBalancerT<MyMesh>  ModBalancer;


#endif
