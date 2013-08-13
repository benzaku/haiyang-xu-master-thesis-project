//
//  GLHandler.cpp
//  MeshStreamingServer
//
//  Created by Xu Haiyang on 18.03.13.
//  Copyright (c) 2013 Haiyang Xu. All rights reserved.
//
#include "GLHandler.h"
#include "GLFBOHelper.h"
#include "matrixUtil.h"
#include "jpge.h"
#include "jpgd.h"

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
int uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};
static GLuint _program;

GLhandleARB _shaderId;

GLHandler::GLHandler()
{
    
}

GLHandler::~GLHandler()
{
    if(this->renderer != NULL){
        delete renderer;
    }
    clear();
}

void
GLHandler::clear()
{
    glDeleteBuffers(1, &_textureId);
    textureId = 0;
    glDeleteFramebuffers(1, &_frameBufferId);
    _frameBufferId = 0;
    glDeleteRenderbuffers(1, &_renderBufferId);
    _renderBufferId = 0;
}

void
GLHandler::initialize(const std::string title, const int width, const int height)
{
    std::cout << "Initialize GL Context" << std::endl;
    
    _width = width;
    _height = height;
    _title =(char *) title.c_str();
    
    initGLUT();
    initGL();
    loadShadowShader();
    generateTexObj();
    generateFrameBuffer();
    renderToFrameBuffer();
}




void
GLHandler::
draw_mesh(VDPMMesh &mesh_){
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glClearColor(0.65, 0.65, 0.65, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    
    
    glUseProgramObjectARB(_shaderId);
    glUniformMatrix4fvARB(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix);
    glUniformMatrix4fvARB(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix);
    
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, mesh_.points());
    
    glEnableClientState(GL_NORMAL_ARRAY);
    glNormalPointer(GL_FLOAT, 0, mesh_.vertex_normals());
    
    /*
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, mesh_.points());
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 12, mesh_.vertex_normals());
    */
    glBegin(GL_TRIANGLES);
    
    VDPMMesh::FaceIter fIt = mesh_.faces_begin(), fEnd = mesh_.faces_end();
    VDPMMesh::ConstFaceVertexIter fvIt;
    for (; fIt!=fEnd; ++fIt)
    {
        fvIt = mesh_.cfv_iter(fIt.handle());
        glArrayElement(fvIt.handle().idx());
        ++fvIt;
        glArrayElement(fvIt.handle().idx());
        ++fvIt;
        glArrayElement(fvIt.handle().idx());
    }
    glEnd();
    //glDisableVertexAttribArray(GLKVertexAttribPosition);
    //glDisableVertexAttribArray(GLKVertexAttribNormal);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    

}
void
GLHandler::
update_viewing_parameters(OpenMesh::VDPM::ViewingParameters &viewing_parameter)
{
    
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    gluPerspective(viewing_parameter.fovy(), viewing_parameter.aspect(),
                   0.01, 10000.0);
    glGetFloatv(GL_PROJECTION_MATRIX, _projectionMatrix);
    
    glMatrixMode( GL_MODELVIEW );
    double modelviewmat[16];
    viewing_parameter.get_modelview_matrix(&modelviewmat[0]);
    glLoadMatrixd(modelviewmat);
    
    
    for(int i = 0; i < 16; i ++){
        _modelViewMatrix[i] = (float)modelviewmat[i];
    }
    
    float invert[9];
    float topleft[9];
    mtx3x3FromTopLeftOf4x4(topleft, _modelViewMatrix);
    mtx3x3Invert(invert, topleft);
    mtx3x3Transpose(_normalMatrix, invert);
    mtxMultiply(_modelViewProjectionMatrix, _projectionMatrix, _modelViewMatrix);
}

void
GLHandler::setDefaultLight()
{
    GLfloat pos1[] = { 0.1,  0.1, -0.02, 0.0};
    GLfloat pos2[] = {-0.1,  0.1, -0.02, 0.0};
    GLfloat pos3[] = { 0.0,  0.0,  0.1,  0.0};
    GLfloat col1[] = { 0.7,  0.7,  0.8,  1.0};
    GLfloat col2[] = { 0.8,  0.7,  0.7,  1.0};
    GLfloat col3[] = { 1.0,  1.0,  1.0,  1.0};
    
    glEnable(GL_LIGHT0);
    glLightfv(GL_LIGHT0,GL_POSITION, pos1);
    glLightfv(GL_LIGHT0,GL_DIFFUSE,  col1);
    glLightfv(GL_LIGHT0,GL_SPECULAR, col1);
    
    glEnable(GL_LIGHT1);
    glLightfv(GL_LIGHT1,GL_POSITION, pos2);
    glLightfv(GL_LIGHT1,GL_DIFFUSE,  col2);
    glLightfv(GL_LIGHT1,GL_SPECULAR, col2);
    
    glEnable(GL_LIGHT2);
    glLightfv(GL_LIGHT2,GL_POSITION, pos3);
    glLightfv(GL_LIGHT2,GL_DIFFUSE,  col3);
    glLightfv(GL_LIGHT2,GL_SPECULAR, col3);
}

void
GLHandler::renderToFrameBuffer()
{
    //currently just clear the background to red
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    
    // draw a rotating teapot at the origin
    glPushMatrix();
    
    glTranslatef(0, -1.575f, -2.5f);
    drawTeapot();
    glPopMatrix();
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

data_chunk*
GLHandler::
getFrameBufferAsJPEGinMen()
{
    GLubyte* pPixelData;
    GLint    i;
    GLint    PixelDataLength;
    
    // 计算像素数据的实际长度
    i = _width * 3;   // 得到每一行的像素数据长度
    while( i%4 != 0 )      // 补充数据，直到i是的倍数
        ++i;               // 本来还有更快的算法，
    // 但这里仅追求直观，对速度没有太高要求
    PixelDataLength = i * _height;
    
    // 分配内存和打开文件
    pPixelData = (GLubyte*)malloc(PixelDataLength);
    if( pPixelData == 0 )
        exit(0);
    // 读取像素
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    //glReadPixels(0, 0, _width, _height, GL_BGR_EXT, GL_UNSIGNED_BYTE, pPixelData);
    glReadPixels(0, 0, _width, _height, GL_RGB, GL_UNSIGNED_BYTE, pPixelData);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    //jpge::compress_image_to_jpeg_file(filename.c_str(), _width, _height, 3, pPixelData);
    
    
    data_chunk * returnData = (data_chunk *) malloc(sizeof(data_chunk));
    char * header = "svrender";
    strncpy(returnData->HEADER, header, 8);
    void * pBuf = (void *) malloc(1024000);
    int buf_size = 1024000;
    
    bool comp = jpge::compress_image_to_jpeg_file_in_memory(pBuf, buf_size, _width, _height, 3, pPixelData);
        
    free(pPixelData);
    
    returnData->size = buf_size;
    returnData->data = (char *)pBuf;
    
    return returnData;
}


data_chunk*
GLHandler::
getFrameBufferAsBMPinMem()
{
    
    FILE*    pDummyFile;
    GLubyte* pPixelData;
    GLubyte  BMP_Header[BMP_Header_Length];
    GLint    i, j;
    GLint    PixelDataLength;
    data_chunk* returnData;
    char * header = "svrender";
    
    // 计算像素数据的实际长度
    i = _width * 3;   // 得到每一行的像素数据长度
    while( i%4 != 0 )      // 补充数据，直到i是的倍数
        ++i;               // 本来还有更快的算法，
    // 但这里仅追求直观，对速度没有太高要求
    PixelDataLength = i * _height;
    
    // 分配内存和打开文件
    pPixelData = (GLubyte*)malloc(PixelDataLength);
    if( pPixelData == 0 )
        exit(0);
    returnData = (data_chunk*)malloc(sizeof(data_chunk));
    strncpy(returnData->HEADER, header, 8);
    returnData->size = PixelDataLength + BMP_Header_Length;
    returnData->data = (char *) malloc(PixelDataLength + BMP_Header_Length);
    
    pDummyFile = fopen("dummy_24_unc.bmp", "rb");
    if( pDummyFile == 0 )
        exit(0);
    
    
    // 读取像素
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    glReadPixels(0, 0, _width, _height,
                 GL_BGR_EXT, GL_UNSIGNED_BYTE, pPixelData);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    // 把dummy.bmp的文件头复制为新文件的文件头
    fread(BMP_Header, sizeof(BMP_Header), 1, pDummyFile);
    // write width and heigh into header
    int * w = (int *) &(BMP_Header[18]);
    *w = _width;
    int * h = (int *) &(BMP_Header[18 + sizeof(int)]);
    *h = _height;
    
    memcpy(returnData->data, BMP_Header, sizeof(BMP_Header));
    memcpy(&(returnData->data[sizeof(BMP_Header)]), pPixelData, PixelDataLength);
    
    FILE*    pWritingFile;
    pWritingFile = fopen("image.bmp", "wb");
    if( pWritingFile == 0 )
        exit(0);
    fwrite(returnData->data, returnData->size, 1, pWritingFile);
    
    // 释放内存和关闭文件
    fclose(pWritingFile);
    fclose(pDummyFile);
    free(pPixelData);

    return returnData;
}


void
GLHandler::
saveFrameBufferAsJPEG(const std::string & filename)
{
    GLubyte* pPixelData;
    GLint    i;
    GLint    PixelDataLength;
    
    // 计算像素数据的实际长度
    i = _width * 3;   // 得到每一行的像素数据长度
    while( i%4 != 0 )      // 补充数据，直到i是的倍数
        ++i;               // 本来还有更快的算法，
    // 但这里仅追求直观，对速度没有太高要求
    PixelDataLength = i * _height;
    
    // 分配内存和打开文件
    pPixelData = (GLubyte*)malloc(PixelDataLength);
    if( pPixelData == 0 )
        exit(0);
    // 读取像素
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    //glReadPixels(0, 0, _width, _height, GL_BGR_EXT, GL_UNSIGNED_BYTE, pPixelData);
    glReadPixels(0, 0, _width, _height, GL_RGB, GL_UNSIGNED_BYTE, pPixelData);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    jpge::compress_image_to_jpeg_file(filename.c_str(), _width, _height, 3, pPixelData);
    
    free(pPixelData);

}


void
GLHandler::saveFrameBufferAsBMP(const std::string & filename)
{
    
    FILE*    pDummyFile;
    FILE*    pWritingFile;
    GLubyte* pPixelData;
    GLubyte  BMP_Header[BMP_Header_Length];
    GLint    i, j;
    GLint    PixelDataLength;
    
    // 计算像素数据的实际长度
    i = _width * 3;   // 得到每一行的像素数据长度
    while( i%4 != 0 )      // 补充数据，直到i是的倍数
        ++i;               // 本来还有更快的算法，
    // 但这里仅追求直观，对速度没有太高要求
    PixelDataLength = i * _height;
    
    // 分配内存和打开文件
    pPixelData = (GLubyte*)malloc(PixelDataLength);
    if( pPixelData == 0 )
        exit(0);
    
    pDummyFile = fopen("dummy_24_unc.bmp", "rb");
    if( pDummyFile == 0 )
        exit(0);
    
    pWritingFile = fopen(filename.c_str(), "wb");
    if( pWritingFile == 0 )
        exit(0);
    
    // 读取像素
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    glReadPixels(0, 0, _width, _height,
                 GL_BGR_EXT, GL_UNSIGNED_BYTE, pPixelData);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    /*
    // 把dummy.bmp的文件头复制为新文件的文件头
    fread(BMP_Header, sizeof(BMP_Header), 1, pDummyFile);
    fwrite(BMP_Header, sizeof(BMP_Header), 1, pWritingFile);
    fseek(pWritingFile, 0x0012, SEEK_SET);
    i = _width;
    j = _height;
    fwrite(&i, sizeof(i), 1, pWritingFile);
    fwrite(&j, sizeof(j), 1, pWritingFile);
    
    // 写入像素数据
    fseek(pWritingFile, 0, SEEK_END);
    fwrite(pPixelData, PixelDataLength, 1, pWritingFile);
    
    // 释放内存和关闭文件
    fclose(pDummyFile);
    fclose(pWritingFile);
    free(pPixelData);
     */
    
    //new way
    // 把dummy.bmp的文件头复制为新文件的文件头
    fread(BMP_Header, sizeof(BMP_Header), 1, pDummyFile);
    //fwrite(BMP_Header, sizeof(BMP_Header), 1, pWritingFile);
    //fseek(pWritingFile, 0x0012, SEEK_SET);
    int * w = (int *) &(BMP_Header[18]);
    *w = _width;
    int * h = (int *) &(BMP_Header[18 + sizeof(int)]);
    *h = _height;
    
    std::cout << *((int *)&(BMP_Header[18])) << " " << *((int *)&(BMP_Header[18 + sizeof(int)])) << std::endl;
    fwrite(BMP_Header, sizeof(BMP_Header), 1, pWritingFile);
    i = _width;
    j = _height;
    //fwrite(&i, sizeof(i), 1, pWritingFile);
    //fwrite(&j, sizeof(j), 1, pWritingFile);
    
    // 写入像素数据
    fseek(pWritingFile, 0, SEEK_END);
    fwrite(pPixelData, PixelDataLength, 1, pWritingFile);
    
    // 释放内存和关闭文件
    fclose(pDummyFile);
    fclose(pWritingFile);
    free(pPixelData);
}

int
GLHandler::initGLUT()
{
    int argc = 0;
    glutInit(&argc, (char **)_title);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH | GLUT_STENCIL);   // display mode
    glutInitWindowSize(_width, _height);              // window size
    glutInitWindowPosition(0, 0);                           // window location
    int handle = glutCreateWindow(_title);     // param is the title of window
    
    std::cout << "Init GLUT completed"<< std::endl;
    return handle;
    //return 0;
}

void
GLHandler::initGL()
{
    glShadeModel(GL_SMOOTH);                    // shading mathod: GL_SMOOTH or GL_FLAT
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);      // 4-byte pixel alignment
    
    // enable /disable features
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_CULL_FACE);
    
    // track material ambient and diffuse from surface color, call it before glEnable(GL_COLOR_MATERIAL)
    //glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
    //glEnable(GL_COLOR_MATERIAL);
    
    glClearColor(0, 0, 0, 0);                   // background color
    glClearStencil(0);                          // clear stencil buffer
    glClearDepth(100.0f);                         // 0 is near, 1 is far
    glDepthFunc(GL_LEQUAL);
    
    initLights();
    std::cout << "Init GL completed" << std::endl;
    
}
void * GLHandler::loadShader(char* filename, unsigned int type)
{
	FILE *pfile;
	GLhandleARB handle;
	const GLcharARB* files[1];
	
	// shader Compilation variable
	GLint result;				// Compilation code result
	GLint errorLoglength ;
	char* errorLogText;
	GLsizei actualErrorLogLength;
	
	char buffer[400000];
	memset(buffer,0,400000);
	
	// This will raise a warning on MS compiler
	pfile = fopen(filename, "rb");
	if(!pfile)
	{
		printf("Sorry, can't open file: '%s'.\n", filename);
		exit(0);
	}
	
	fread(buffer,sizeof(char),400000,pfile);
	//printf("%s\n",buffer);
	
	
	fclose(pfile);
	
	handle = glCreateShaderObjectARB(type);
	if (!handle)
	{
		//We have failed creating the vertex shader object.
		printf("Failed creating vertex shader object from file: %s.",filename);
		exit(0);
	}
	
	files[0] = (const GLcharARB*)buffer;
	glShaderSourceARB(
					  handle, //The handle to our shader
					  1, //The number of files.
					  files, //An array of const char * data, which represents the source code of theshaders
					  NULL);
	
	glCompileShaderARB(handle);
	
	//Compilation checking.
	glGetObjectParameterivARB(handle, GL_OBJECT_COMPILE_STATUS_ARB, &result);
	
	// If an error was detected.
	if (!result)
	{
		//We failed to compile.
		printf("Shader '%s' failed compilation.\n",filename);
		
		//Attempt to get the length of our error log.
		glGetObjectParameterivARB(handle, GL_OBJECT_INFO_LOG_LENGTH_ARB, &errorLoglength);
		
		//Create a buffer to read compilation error message
		errorLogText = (char *)malloc(sizeof(char) * errorLoglength);
		
		//Used to get the final length of the log.
		glGetInfoLogARB(handle, errorLoglength, &actualErrorLogLength, errorLogText);
		
		// Display errors.
		printf("%s\n",errorLogText);
		
		// Free the buffer malloced earlier
		free(errorLogText);
	}
	
	return handle;
}

void GLHandler::loadShadowShader()
{
	GLhandleARB vertexShaderHandle;
	GLhandleARB fragmentShaderHandle;
	
	vertexShaderHandle   = loadShader("Phong.vsh",GL_VERTEX_SHADER);
	fragmentShaderHandle = loadShader("Phong.fsh",GL_FRAGMENT_SHADER);
	
	_shaderId = glCreateProgramObjectARB();
	
	glAttachObjectARB(_shaderId,vertexShaderHandle);
	glAttachObjectARB(_shaderId,fragmentShaderHandle);
    //glBindAttribLocationARB(_shaderId, GLKVertexAttribPosition, "position");
    //glBindAttribLocationARB(_shaderId, GLKVertexAttribNormal, "normal");
	glLinkProgramARB(_shaderId);
	
	//shadowMapUniform = glGetUniformLocationARB(shadowShaderId,"ShadowMap");
    //uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocationARB(_shaderId, "modelViewProjectionMatrix");
    //uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocationARB(_shaderId, "normalMatrix");
    
}

bool
GLHandler::loadShaders()
{
    GLuint vertShader, fragShader;
    
    // Create shader program.
    _program = glCreateProgram();
        
    // Create and compile vertex shader.    
    if (!compileShader(&vertShader, GL_VERTEX_SHADER, "Shader.vsh")) {
        std::cout << "Failed to compile vertex shader" << std::endl;
        return false;
    }
    
    // Create and compile fragment shader.
    if (!compileShader(&fragShader, GL_FRAGMENT_SHADER, "Shader.fsh")) {
        std::cout <<"Failed to compile fragment shader" << std::endl;
        return false;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (!linkProgram(_program)) {
        std::cout << "Failed to link program: " <<  _program << std::endl;
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return false;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return true;

}




bool
GLHandler::
compileShader(unsigned int *shader, unsigned int type, char* filename)
{
    GLint status;
    const GLchar *source;
    FILE *pfile;
    
    char buffer[400000];
	memset(buffer,0,400000);
	
	// This will raise a warning on MS compiler
	pfile = fopen(filename, "rb");
	if(!pfile)
	{
		printf("Sorry, can't open file: '%s'.\n", filename);
		exit(0);
	}
	
	fread(buffer,sizeof(char),400000,pfile);
    fclose(pfile);
    
    source = (GLchar *) buffer;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        printf("Shader compile log:\n%s\n", log);
        free(log);
    }
    
    char * glversion = (char *)glGetString(GL_VERSION);
    
    std::cout << glversion << std::endl;
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return false;
    }
    
    return true;
}

bool
GLHandler::linkProgram(unsigned int prog)
{
    GLint status;
    glLinkProgram(prog);
    
    GLint logLength;
    GLchar *log = (GLchar *)malloc(1024);
    glGetProgramInfoLog(prog, 1024, &logLength, log);
    if (logLength > 0) {
        printf("Shader link fail! \n%s\n", log);

    }
    free(log);
    
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return false;
    }
    
    return true;
}

void
GLHandler::initLights()
{
    
    // set up light colors (ambient, diffuse, specular)
    GLfloat lightKa[] = {1.f, 0.4f, 0.4f, 1.0f};  // ambient light
    GLfloat lightKd[] = {1.0f, 0.4f, 0.4f, 1.0f};  // diffuse light
    GLfloat lightKs[] = {1, 1, 1, 1};           // specular light
    //glLightfv(GL_LIGHT0, GL_AMBIENT, lightKa);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightKd);
    //glLightfv(GL_LIGHT0, GL_SPECULAR, lightKs);
    
    // position the light
    float lightPos[3] = {0.0f, 0.0f, 1.0f}; // positional light
    glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
    
    glEnable(GL_LIGHT0);                        // MUST enable each light source after configuration
}

void
GLHandler::generateTexObj()
{// create a texture object
    glGenTextures(1, &_textureId);
    glBindTexture(GL_TEXTURE_2D, _textureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE); // automatic mipmap generation included in OpenGL v1.4
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

void
GLHandler::generateFrameBuffer()
{
    // create a framebuffer object, you need to delete them when program exits.
    glGenFramebuffers(1, &_frameBufferId);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferId);
    
    // create a renderbuffer object to store depth info
    // NOTE: A depth renderable image should be attached the FBO for depth test.
    // If we don't attach a depth renderable image to the FBO, then
    // the rendering output will be corrupted because of missing depth test.
    // If you also need stencil test for your rendering, then you must
    // attach additional image to the stencil attachement point, too.
    glGenRenderbuffers(1, &_renderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, _width, _height);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    
    // attach a texture to FBO color attachement point
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureId, 0);
    
    // attach a renderbuffer to depth attachment point
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _renderBufferId);
    
    // check FBO status
    bool status = checkFramebufferStatus();
    if(!status){
        _fboUsed = false;
        std::cout << "Problem in Frame buffer init" << std::endl;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
}
///////////////////////////////////////////////////////////////////////////////
// check FBO completeness
///////////////////////////////////////////////////////////////////////////////
bool
GLHandler::checkFramebufferStatus()
{
    // check FBO status
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status)
    {
        case GL_FRAMEBUFFER_COMPLETE:
            std::cout << "Framebuffer complete." << std::endl;
            return true;
            
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
            std::cout << "[ERROR] Framebuffer incomplete: Attachment is NOT complete." << std::endl;
            return false;
            
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            std::cout << "[ERROR] Framebuffer incomplete: No image is attached to FBO." << std::endl;
            return false;
            
        case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:
            std::cout << "[ERROR] Framebuffer incomplete: Draw buffer." << std::endl;
            return false;
            
        case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:
            std::cout << "[ERROR] Framebuffer incomplete: Read buffer." << std::endl;
            return false;
            
        case GL_FRAMEBUFFER_UNSUPPORTED:
            std::cout << "[ERROR] Framebuffer incomplete: Unsupported by FBO implementation." << std::endl;
            return false;
            
        default:
            std::cout << "[ERROR] Framebuffer incomplete: Unknown error." << std::endl;
            return false;
    }
}


