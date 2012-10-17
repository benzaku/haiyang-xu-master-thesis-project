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
    
    MyMesh::Point bbMin, bbMax;
    
    bbMin = bbMax = baseMesh.point(vIt);
    
    for(; vIt != vEnd; ++vIt){
        bbMin.minimize(baseMesh.point(vIt));
        bbMax.maximize(baseMesh.point(vIt));
    }
    
    //set center and radius
    center = 0.5f*(bbMin + bbMax);
    radius = 0.5*(bbMin - bbMax).norm();
    
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
    }
    
    baseMesh.update_face_normals();
    baseMesh.update_vertex_normals();
    [self updateBaseMeshGLArray];
    
}


@end
