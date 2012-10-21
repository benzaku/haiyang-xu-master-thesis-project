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
        VerticeNormalGLArray = NULL;
        BASE_MESH_VERTEX_NORMAL_ARRAY = NULL;
        BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE = 0;
        BASE_MESH_INDICE_ARRAY = 0;
        MESH_INDICE_ARRAY = NULL;
        MESH_INDICE_ARRAY_SIZE = 0;
        
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
    
    GLubyte *temp = [self getBaseMeshGLArray];
    
    GLsizei tempsize= [self getBaseMeshGLArraySize];
    
    GLfloat * tf = (GLfloat *)temp;
    
    nVertices = nBaseVertices;
    nFaces = nBaseFaces;
    
    NSLog(@"tempsize = %d", tempsize);
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

- (void) updateBaseMeshGLArray
{
    //baseMeshGLArraySize = (nFaces) * 18 * sizeof(float);
    
    MyMesh::ConstFaceIter   fIt(baseMesh.faces_begin()), fEnd(baseMesh.faces_end());
    MyMesh::ConstFaceVertexIter     fvIt;
    int counter = 0;
    int cnt = 0;
    for(; fIt != fEnd; ++fIt){
        fvIt = baseMesh.cfv_iter(fIt.handle());
        
        //cord of 1st vertex
        
        memcpy(&baseMeshGLArray[counter], &baseMesh.point(fvIt)[0], 3 * sizeof(float));
        counter += (3 * sizeof(float));
        //normal of 1st vertex
        memcpy(&baseMeshGLArray[counter], &baseMesh.normal(fvIt)[0], 3 * sizeof(float));
        counter += (3 * sizeof(float));
        
        ++fvIt;
        //cord of 2nd vertex
        memcpy(&baseMeshGLArray[counter], &baseMesh.point(fvIt)[0], 3 * sizeof(float));
        counter += (3 * sizeof(float));
        //normal of 2nd vertex
        memcpy(&baseMeshGLArray[counter], &baseMesh.normal(fvIt)[0], 3 * sizeof(float));
        counter += (3 * sizeof(float));
        
        ++fvIt;
        //cord of 3rd vertex
        memcpy(&baseMeshGLArray[counter], &baseMesh.point(fvIt)[0], 3 * sizeof(float));
        counter += (3 * sizeof(float));
        //normal of 1st vertex
        memcpy(&baseMeshGLArray[counter], &baseMesh.normal(fvIt)[0], 3 * sizeof(float));
        counter += (3 * sizeof(float));
        
        ++cnt;
    }
    baseMeshGLArraySize = cnt * 18 * sizeof(float);
    //NSLog(@"update finished!");
}

- (GLubyte *) getBaseMeshGLArray
{
    //NSLog(@"big size: %ld", (nBaseFaces + nDetailVertices) * 18 * sizeof(float));
    
    if(baseMeshGLArray == NULL){
        baseMeshGLArray = new GLubyte[(nBaseFaces + nDetailVertices * 2) * 18 * sizeof(float)];
        [self updateBaseMeshGLArray];
    }
    
    return baseMeshGLArray;
}
- (GLsizei ) getBaseMeshGLArraySize
{
    return baseMeshGLArraySize;
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

- (void) refine: (int) steps
{
    PMInfo *pminfo;
    
    
    for(int i = 0 ; i < steps; i ++){
        
        pminfo = &(details[currentPointer]);
        
        pminfo->v0 = baseMesh.add_vertex(pminfo->p0);
        baseMesh.vertex_split(pminfo->v0,
                           pminfo->v1,
                           pminfo->vl,
                           pminfo->vr);
        
        nVertices ++;
        nFaces ++;
        currentPointer ++;
        
        
        BBMAX.maximize(pminfo->p0);
        BBMIN.minimize(pminfo->p0);
        center = 0.5f*(BBMAX + BBMIN);
        radius = 0.5*(BBMIN - BBMAX).norm();
    }
    
    baseMesh.update_face_normals();
    baseMesh.update_vertex_normals();
    [self updateBaseMeshGLArray];
    
}

- (void) clear
{
    baseMesh.clean();
    details.clear();
    center[0], center[1] = 0, center[2] = 0;
    radius = 0;
    baseMeshGLArraySize = 0;
    delete [] baseMeshGLArray;
    baseMeshGLArray = NULL;
    currentPointer = 0;
    
}

- (void) updateVerticePositionAndNormalGLArray
{
    MyMesh::VertexHandle vh;
    MyMesh::Normal vn;
    MyMesh::Point p;
    
    
    float * pos;
    float * nor;
    
    for(int i = currentVerticeIdx; i < nCurrentVertices; i ++){
        vh = baseMesh.vertex_handle(i);
        vn = baseMesh.normal(vh);
        p = baseMesh.point(vh);
        
        pos = (float *)&verticeGLArray[i * 3 * sizeof(float)];
        
        pos[0] = p.values_[0];
        pos[1] = p.values_[1];
        pos[2] = p.values_[2];
        
        nor = (float *)&normalGLArray[i * 3 * sizeof(float)];
        nor[0] = vn.values_[0];
        nor[1] = vn.values_[1];
        nor[2] = vn.values_[2];
        
    }
    
    
}

- (void) updateVerticeNormalGLArray
{
    
}


- (GLubyte *) getVerticePositionGLArray
{
    if(verticeGLArray == NULL){
        verticeGLArray = new GLubyte[(nBaseVertices + nDetailVertices)* 3 * sizeof(float)];
        [self updateVerticePositionAndNormalGLArray];
    }
    
    return verticeGLArray;
    
}
- (GLubyte *) getVerticeNormalGLArray
{
    if (VerticeNormalGLArray == NULL) {
        VerticeNormalGLArray = new GLubyte[2 * (nBaseVertices + nDetailVertices)* 3 * sizeof(float)];
        
    }
    return normalGLArray;
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
    BASE_MESH_VERTEX_NORMAL_ARRAY = new GLfloat[BASE_MESH_VERTEX_NORMAL_ARRAY_SIZE];
    
    
    MyMesh::VertexHandle vh;
    MyMesh::Normal vn;
    MyMesh::Point p;
    
    
    for(int i = 0; i < nBaseVertices; i ++){
        vh = baseMesh.vertex_handle(i);
        vn = baseMesh.normal(vh);
        p = baseMesh.point(vh);
        
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[i * 2 * 3]), &(p.values_[0]), 3 * sizeof(float));
        memcpy(&(BASE_MESH_VERTEX_NORMAL_ARRAY[i * 2 * 3 + 3]), &(vn.values_[0]), 3 * sizeof(float));
        
    }

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


- (void) generateInitMeshIndiceArray
{
    if (MESH_INDICE_ARRAY != NULL) {
        delete [] MESH_INDICE_ARRAY;
        MESH_INDICE_ARRAY_SIZE = 0;
    }
    
    MESH_INDICE_ARRAY_SIZE = 3 * (nBaseFaces + 2 * nDetailVertices) * sizeof(int);
    MESH_INDICE_ARRAY = new GLubyte[MESH_INDICE_ARRAY_SIZE];
    
    MyMesh::ConstFaceIter   fIt(baseMesh.faces_begin()), fEnd(baseMesh.faces_end());
    MyMesh::ConstFaceVertexIter     fvIt;
    
    
    int cnt = 0;
    
    int * p_indice = (int *)&(MESH_INDICE_ARRAY[0]);
    
    for(; fIt != fEnd; ++fIt){
        fvIt = baseMesh.cfv_iter(fIt.handle());
        for(int i = 0; i < 3; i ++){
            *p_indice = (fvIt.handle()).idx();
            ++ p_indice;
            ++fvIt;
        }
        ++cnt;
    }


}
- (GLubyte *) getMeshIndiceArray
{
    if (MESH_INDICE_ARRAY == NULL) {
        [self generateInitMeshIndiceArray];
    }
    return MESH_INDICE_ARRAY;
    
}


@end
