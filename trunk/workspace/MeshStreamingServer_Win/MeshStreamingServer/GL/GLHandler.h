//
//  GLHandler.h
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 18.03.13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//

#ifndef __MeshStreamingServer__GLHandler__
#define __MeshStreamingServer__GLHandler__

#include <iostream>
#include "Singleton.h"
#include "GLRenderer.h"
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>
#include <OpenMesh/Tools/VDPM/ViewingParameters.hh>
#include <OpenMesh/TOOLs/VDPM/MeshTraits.hh>
#include "PublicIncludes.h"
//typedef OpenMesh::TriMesh_ArrayKernelT<OpenMesh::VDPM::MeshTraits> MyMesh;

typedef enum {
    GLKVertexAttribPosition,
    GLKVertexAttribNormal,
    GLKVertexAttribColor,
    GLKVertexAttribTexCoord0,
    GLKVertexAttribTexCoord1,
} GLKVertexAttrib;


class GLHandler : public  Singleton{
private:
    GLHandler();
    ~GLHandler();
    
    int initGLUT();
    
    void initGL();
    
    void initLights();
    
    void generateTexObj();
    
    void generateFrameBuffer();
    
    bool checkFramebufferStatus();
    
    void setDefaultLight();

    
public:
    
    void draw_mesh(VDPMMesh &mesh_);
    
    void update_viewing_parameters(OpenMesh::VDPM::ViewingParameters &viewing_parameter);

    void initialize(const std::string title, const int width, const int height);
    
    void saveFrameBufferAsBMP(const std::string & filename);
    
    void saveFrameBufferAsJPEG(const std::string & filename);
    
    data_chunk* getFrameBufferAsBMPinMem();
    
    data_chunk* getFrameBufferAsJPEGinMen();
    
    void renderToFrameBuffer();
    
    void clear();

private:
    GLRenderer * renderer = NULL;
    
    int _width = 0, _height = 0;
    
    char * _title;
    
    
    bool loadShaders();
    
    void * loadShader(char* filename, unsigned int type);


    bool compileShader(unsigned int *shader, unsigned int type, char * filename);

    bool linkProgram(unsigned int prog);
    void loadShadowShader();


public:
    unsigned int _textureId, _frameBufferId, _renderBufferId;
    
    bool _fboSupported, _fboUsed;
    
    float _modelViewMatrix[16];
    
    float _projectionMatrix[16];
    
    float _normalMatrix[9];
    
    float _modelViewProjectionMatrix[16];
};

#endif /* defined(__MeshStreamingServer__GLHandler__) */
