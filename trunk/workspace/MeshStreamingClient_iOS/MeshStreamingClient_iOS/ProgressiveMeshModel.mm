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

- (id)init
{
    NSLog(@"ProgressiveMeshModel Init...");
    if(self=[super init]){ 
        nBaseVertices = 0;
        nBaseFaces = 0;
        nMaxVertices = 0;
        nDetailVertices = 0;
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

    unsigned int * ui = (unsigned int *) &(mesh[self.nBaseVertices * sizeof(MyMesh::Point)]);
    NSLog(@"ui = %d", *ui);
    
    MyMesh::Point * ppp = (MyMesh::Point *) &(mesh[(self.nBaseVertices -1) * sizeof(MyMesh::Point)]);
    
    
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
    NSLog(@"There are %u details", nDetails);
    
    
    char * details = new char[[data length]];
    
    [data getBytes:details length:[data length]];
    
    membuf sbuf(details, details + [data length]);
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
}



@end
