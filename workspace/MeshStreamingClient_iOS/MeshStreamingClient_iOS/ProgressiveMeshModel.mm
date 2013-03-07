//
//  ProgressiveMeshModel.m
//  MeshStreamingClient_iOS
//
//  Created by Haiyang Xu on 04.10.12.
//  Copyright (c) 2012 Haiyang Xu. All rights reserved.
//

#import "ProgressiveMeshModel.h"

#include <OpenMesh/Core/Utils/Endian.hh>
#include <iostream>

@implementation ProgressiveMeshModel

@synthesize nMaxVertices;
@synthesize nBaseVertices;
@synthesize nBaseFaces;
@synthesize nDetailVertices;
@synthesize sizeBaseMesh;
@synthesize center;
@synthesize radius;
@synthesize nVertices;
@synthesize nFaces;

- (id)init
{
    NSLog(@"ProgressiveMeshModel Init...");
    if(self=[super init]){ 
        nBaseVertices = 0;
        nBaseFaces = 0;
        nMaxVertices = 0;
        nDetailVertices = 0;
        baseMeshGLArray = NULL;
        baseMeshGLArraySize = 0;
        pmiter = details.begin();
        currentPointer = 0;
        nVertices = 0;
        nFaces = 0;
        verticeGLArray = NULL;
        normalGLArray = NULL;
        currentVerticeIdx = 0;
        nCurrentVertices = 0;
        VerticeNormalGLArray = NULL;
        BASE_MESH_VERTEX_NORMAL_ARRAY = NULL;
        BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 0;
        BASE_MESH_INDICE_ARRAY = 0;
        MESH_INDICE_ARRAY = NULL;
        MESH_INDICE_ARRAY_SIZE = 0;
        TOTAL_VERTEX_NORMAL_ARRAY_SIZE = 0;
        TOTAL_FACE_INDICE_BUFFER_SIZE = 0;
        BASE_MESH_INDICE_BUFFER_SIZE = 0;
        currentOffset = NULL;
        currentRecoveredFaceNumber = 0;
        
    }
    //MyMesh mesh;
    return self;
}

- (NSData *)getBaseMeshChunk
{
    return baseMeshChunk;
}


- (void)setBaseMeshChunk:(NSData *)data
{
    
    
    baseMeshChunk = [[NSData alloc] initWithData:data];
    
    char * mesh = new char[[data length]];
    
    [data getBytes:mesh length:[data length]];
    
    membuf sbuf(mesh, mesh + [data length]);
    std::istream meshis(&sbuf);
    
    
    //load base mesh
    MyMesh::Point p;
    unsigned int   i0, i1, i2;
    NSInteger sizePoint = sizeof(p);
    NSInteger sizeUnInt = sizeof(unsigned int);
    
    for (int i = 0; i < nBaseVertices; i ++) {
        //load base vertices
        meshis.read((char *)&p, sizePoint);
        baseMesh.add_vertex(p);
    }
    
    for (int i = 0; i < nBaseFaces; i ++) {
        //load base faces
        meshis.read((char *)&i0, sizeof(unsigned int));
        meshis.read((char *)&i1, sizeUnInt);
        meshis.read((char *)&i2, sizeUnInt);
        
        baseMesh.add_face(baseMesh.vertex_handle(i0),
                          baseMesh.vertex_handle(i1),
                          baseMesh.vertex_handle(i2));
    }

    baseMesh.update_face_normals();
    baseMesh.update_vertex_normals();
    MyMesh::ConstVertexIter
    vIt(baseMesh.vertices_begin()),
    vEnd(baseMesh.vertices_end());
    
    //MyMesh::Point bbMin, bbMax;
    
    BBMIN = BBMAX = baseMesh.point(vIt);
    
    for(; vIt != vEnd; ++vIt){
        BBMIN.minimize(baseMesh.point(vIt));
        BBMAX.maximize(baseMesh.point(vIt));
    }
    
    //set center and radius
    center = 0.5f*(BBMIN + BBMAX);
    radius = 0.5*(BBMIN - BBMAX).norm();
    nVertices = nBaseVertices;
    nFaces = nBaseFaces;
    
}

- (void)addPMDetail:(PMInfo)pminfo
{
    if(details.size() < nDetailVertices){
        details.push_back(pminfo);
    }
    else{
        NSLog(@"Detail List Already FULL!");
    }
}

- (void)addPMDetailsFromNSData:(NSData *)data
{
    
    MyMesh::Point p;
    unsigned int v1, vl, vr;
    NSInteger sizePMInfo = 24;
    NSInteger sizePoint = sizeof(p);
    NSInteger sizeUnInt = sizeof(unsigned int);
    NSInteger nDetails =  data.length / sizePMInfo;
    //NSLog(@"There are %u details", nDetails);
    
    
    char * detailschars = new char[[data length]];
    
    [data getBytes:detailschars length:[data length]];
    
    membuf sbuf(detailschars, detailschars + [data length]);
    std::istream detailis(&sbuf);

    for(int i = 0; i < nDetails; i ++){
        detailis.read((char *)&p, sizePoint);
        detailis.read((char *)&v1, sizeUnInt);
        detailis.read((char *)&vl, sizeUnInt);
        detailis.read((char *)&vr, sizeUnInt);
        
        PMInfo pminfo;
        pminfo.p0 = p;
        pminfo.v1 = MyMesh::VertexHandle(v1);
        pminfo.vl = MyMesh::VertexHandle(vl);
        pminfo.vr = MyMesh::VertexHandle(vr);
        self->details.push_back(pminfo);
    }
    delete [] detailschars;
}

- (PMInfoIter) getPMInfoIter
{
    return pmiter;
}

- (PMInfoIter) getDetailsEnd
{
    return details.end();
}

- (void) incPMInfoIter
{
    pmiter++;
}

- (size_t) getDetailSize
{
    return details.size();
}

- (size_t) getCurrentPointer
{
    return currentPointer;
}

- (void) incCurrentPointer: (int) times
{
    for(int i = 0; i < times; i ++)
        currentPointer ++;
}

- (UpdateInfo *) refineWithOffset: (int) steps: (int &) offset: (int &) size
{
    
    PMInfo *pminfo;
    
    offset = currentVerticeIdx * 3 * 2 * sizeof(float);
    size = steps * 3 * 2 * sizeof(float);
    
    
    updatePartIndex.clear();
    indicePartIndex.clear();
    
    for(int i = 0 ; i < steps; i ++){
        
        std::vector<int> v0, v1, v0new, v1new;
        
        int idx;
        int nv0 = 0, nv1 = 0, nv11 = 0;
        
        pminfo = &(details[currentPointer]);
        
        for (MyMesh::VertexFaceIter vfiter = baseMesh.vf_begin(pminfo->v1); vfiter != baseMesh.vf_end(pminfo->v1); ++ vfiter) {
            nv11 ++;
        }
        
        pminfo->v0 = baseMesh.add_vertex(pminfo->p0);
        
        baseMesh.vertex_split(pminfo->v0,
                              pminfo->v1,
                              pminfo->vl,
                              pminfo->vr);
        
        // update the vertex position
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[nVertices * 3 * 2]), pminfo->p0.data(), 3 * sizeof(float));
        updatePartIndex.insert(nVertices * 3 * 2);
        nVertices ++;
        nFaces += 2;
        currentPointer ++;
        nCurrentVertices ++;
        currentVerticeIdx ++;
        //currentRecoveredFaceNumber += 2;
        
        BBMAX.maximize(pminfo->p0);
        BBMIN.minimize(pminfo->p0);
        center = 0.5f*(BBMAX + BBMIN);
        radius = 0.5*(BBMIN - BBMAX).norm();
        //updating affected face normals and vertex normals
        // face normals
        for (MyMesh::VertexFaceIter vfiter = baseMesh.vf_begin(pminfo->v0); vfiter != baseMesh.vf_end(pminfo->v0); ++ vfiter) {
            baseMesh.update_normal(vfiter.handle());
            
            nv0 ++;
            // update indice
            MyMesh::ConstFaceVertexIter cfviter = baseMesh.cfv_iter(vfiter.handle());
            
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
        for (MyMesh::VertexFaceIter vfiter = baseMesh.vf_begin(pminfo->v1); vfiter != baseMesh.vf_end(pminfo->v1); ++ vfiter) {
            baseMesh.update_normal(vfiter.handle());
            nv1 ++;
        }
        
        currentRecoveredFaceNumber += ((nv1 + nv0 - nv11) / 2);
        for (MyMesh::VertexVertexIter vviter = baseMesh.vv_begin(pminfo->v0); vviter != baseMesh.vv_end(pminfo->v0); ++ vviter) {
            baseMesh.update_normal(vviter.handle());
            // update normal in vertex normal array
            memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[vviter.handle().idx() * 3 * 2 + 3]), baseMesh.normal(vviter.handle()).data(), 3 * sizeof(float));
            
            updatePartIndex.insert(vviter.handle().idx() * 3 * 2 + 3);
        }

        for (MyMesh::VertexVertexIter vviter = baseMesh.vv_begin(pminfo->v1); vviter != baseMesh.vv_end(pminfo->v1); ++ vviter) {
            baseMesh.update_normal(vviter.handle());
            baseMesh.update_normal(vviter.handle());
            // update normal in vertex normal array
            memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[vviter.handle().idx() * 3 * 2 + 3]), baseMesh.normal(vviter.handle()).data(), 3 * sizeof(float));
            
            updatePartIndex.insert(vviter.handle().idx() * 3 * 2 + 3);
        }
        
        
        

    }
    
    updateInfo = std::make_pair(&updatePartIndex, &indicePartIndex);
    
    return &updateInfo;
}



- (void) updateVertexNormalArray
{
    MyMesh::VertexHandle vh;
    MyMesh::Normal vn;
    MyMesh::Point p;
    MyMesh::VertexIter v_it, v_end(baseMesh.vertices_end());
    
    
    
    float * pos;
    float * nor;
    
    for(;currentVerticeIdx < nCurrentVertices; currentVerticeIdx ++){
        vh = baseMesh.vertex_handle(currentVerticeIdx);
        vn = baseMesh.normal(vh);
        p = baseMesh.point(vh);
        
        pos = (float *)&BASE_MESH_VERTEX_NORMAL_ARRAY[currentVerticeIdx * 3 * 2 ];
        
        pos[0] = p.values_[0];
        pos[1] = p.values_[1];
        pos[2] = p.values_[2];
        
        
        
        nor = (float *)&BASE_MESH_VERTEX_NORMAL_ARRAY[currentVerticeIdx * 3 * 2 + 3];
        nor[0] = vn.values_[0];
        nor[1] = vn.values_[1];
        nor[2] = vn.values_[2];
        
    }

}

- (void) clear
{
    baseMesh.clean();
    details.clear();
    center[0], center[1] = 0, center[2] = 0;
    radius = 0;
    baseMeshGLArraySize = 0;
    currentPointer = 0;
    
    nBaseVertices = 0;
    nBaseFaces = 0;
    nMaxVertices = 0;
    nDetailVertices = 0;
    
    baseMeshGLArraySize = 0;
    pmiter = details.begin();
    currentPointer = 0;
    nVertices = 0;
    nFaces = 0;
    
    currentVerticeIdx = 0;
    nCurrentVertices = 0;
    //VerticeNormalGLArray = NULL;
    delete [] BASE_MESH_VERTEX_NORMAL_ARRAY;
    BASE_MESH_VERTEX_NORMAL_ARRAY = NULL;
    BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 0;
    BASE_MESH_INDICE_ARRAY = 0;
    delete [] MESH_INDICE_ARRAY;
    MESH_INDICE_ARRAY = NULL;
    MESH_INDICE_ARRAY_SIZE = 0;
    TOTAL_VERTEX_NORMAL_ARRAY_SIZE = 0;
    TOTAL_FACE_INDICE_BUFFER_SIZE = 0;
    BASE_MESH_INDICE_BUFFER_SIZE = 0;
    currentOffset = NULL;
    currentRecoveredFaceNumber = 0;
    
}

- (GLsizei ) getCurrentFaceNumber
{
    return currentFaceNumber;
}

- (void) generateBaseMeshVertexNormalArray
{
    if(BASE_MESH_VERTEX_NORMAL_ARRAY != NULL){
        delete [] BASE_MESH_VERTEX_NORMAL_ARRAY;
        BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 0;
    }
    BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 2 * nBaseVertices * 3;
    
    
    
    BASE_MESH_VERTEX_NORMAL_ARRAY = new GLfloat[[self getTotalVertexNormalArraySize]];
    for(int i = 0; i < [self getTotalVertexNormalArraySize]; i ++)
        BASE_MESH_VERTEX_NORMAL_ARRAY[i] = 0.0f;
    
    MyMesh::VertexHandle vh;
    MyMesh::Normal vn;
    MyMesh::Point p;
    
    MyMesh::VertexIter v_it, v_end(baseMesh.vertices_end());
    
    for(v_it = baseMesh.vertices_begin(); v_it!= v_end; ++v_it){
        p = baseMesh.point(v_it);
        vn = baseMesh.normal(v_it);
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[v_it.handle().idx() * 2 * 3]), &(p.values_[0]), 3 * sizeof(float));
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[v_it.handle().idx() * 2 * 3 + 3]), &(vn.values_[0]), 3 * sizeof(float));
        
        //update current vertex idx
        currentVerticeIdx = v_it.handle().idx();
        nCurrentVertices ++;
    }
    currentVerticeIdx ++;
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

- (int) getMeshIndiceArraySize
{
    return MESH_INDICE_ARRAY_SIZE;
}

- (void) updateMeshIndiceArray
{
    MyMesh::ConstFaceIter   fIt(baseMesh.faces_begin()), fEnd(baseMesh.faces_end());
    MyMesh::ConstFaceVertexIter     fvIt;
    
    
    int cnt = 0;
    int facecount = 0;    
    unsigned int * indice_array = MESH_INDICE_ARRAY;
    
    for(; fIt != fEnd; ++fIt){
        fvIt = baseMesh.cfv_iter(fIt.handle());
        for(int i = 0; i < 3; i ++){
            
            indice_array[cnt] = (fvIt.handle().idx());
            ++fvIt;
            ++cnt;
            
        }
        ++facecount;
        
        
        
    }
    currentRecoveredFaceNumber = facecount;

}

- (void) generateInitMeshIndiceArray
{
    if (MESH_INDICE_ARRAY != NULL) {
        delete [] MESH_INDICE_ARRAY;
        MESH_INDICE_ARRAY_SIZE = 0;
    }
    
    MESH_INDICE_ARRAY_SIZE = 3 * (nBaseFaces + 2 * nDetailVertices) ;
    MESH_INDICE_ARRAY = new unsigned int[MESH_INDICE_ARRAY_SIZE];
    
    MyMesh::ConstFaceIter   fIt(baseMesh.faces_begin()), fEnd(baseMesh.faces_end());
    MyMesh::ConstFaceVertexIter     fvIt;
    
    
    int cnt = 0;
    
    unsigned int * p_indice = (unsigned int *)&(MESH_INDICE_ARRAY[0]);
    
    for(; fIt != fEnd; ++fIt){
        fvIt = baseMesh.cfv_iter(fIt.handle());
        for(int i = 0; i < 3; i ++){
            *p_indice = (fvIt.handle()).idx();
            ++ p_indice;
            ++fvIt;
            ++cnt;
        }
        
    }
    currentRecoveredFaceNumber = nBaseFaces;

}
- (unsigned int *) getMeshIndiceArray
{
    if (MESH_INDICE_ARRAY == NULL) {
        [self generateInitMeshIndiceArray];
    }
    return MESH_INDICE_ARRAY;
    
}

- (GLsizei) getTotalVertexNormalArraySize
{
    if(TOTAL_VERTEX_NORMAL_ARRAY_SIZE == 0){
        TOTAL_VERTEX_NORMAL_ARRAY_SIZE = (nBaseVertices + nDetailVertices) * 3 * 2;
    }
    
    return TOTAL_VERTEX_NORMAL_ARRAY_SIZE;
}

- (GLsizei) getTotalFaceIndiceBufferSize
{
    if (TOTAL_FACE_INDICE_BUFFER_SIZE == 0) {
        TOTAL_FACE_INDICE_BUFFER_SIZE = (nBaseFaces + 2 * nDetailVertices) * 3 * sizeof(unsigned int);
    }
    
    return TOTAL_FACE_INDICE_BUFFER_SIZE;
}

- (GLsizei) getBaseMeshIndiceBufferSize
{
    if (BASE_MESH_INDICE_BUFFER_SIZE == 0) {
        BASE_MESH_INDICE_BUFFER_SIZE = nBaseFaces * 3 * sizeof(int);
    }
    
    return BASE_MESH_INDICE_BUFFER_SIZE;
}

- (int) getFaceNumber
{
    MyMesh::FaceIter fend = baseMesh.faces_end();
    MyMesh::FaceHandle fh = fend.handle();
    return fh.idx();
}

- (int) getCurrentRecoveredFacesNumber
{
    return currentRecoveredFaceNumber;
}

@end
