//
//  ProgMeshGLKViewController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/14/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ProgMeshGLKViewController.h"
#include "AdditionalIncludes.h"
#import "VDPMModel.h"
#import "AppDelegate.h"
#import "Pair.h"


const double TRACKBALL_RADIUS = 0.6;



@interface ProgMeshGLKViewController (){
    
    GLuint _program;
    
    GLuint _vertexArray;
    
    GLuint _vertexBuffer;
    
    CGPoint _rotation;
    
    bool last_point_ok_;
    
    OpenMesh::Vec3f  last_point_3D_;
    
    GLKMatrix4 baseModelViewMatrix;
    
    GLKMatrix4 projectionMatrix;
    
    GLKMatrix4 _modelViewMatrix;
    
    //Quaternion things
    GLKMatrix4 _rotMatrix;
    GLKVector3 _anchor_position;
    GLKVector3 _current_position;
    GLKQuaternion _quatStart;
    GLKQuaternion _quat;
    
    BOOL _slerping;
    float _slerpCur;
    float _slerpMax;
    GLKQuaternion _slerpStart;
    GLKQuaternion _slerpEnd;
    
    float _curRed;
    BOOL _increasing;
    
    float zoomDistance;
    
    float translateX;
    
    float translateY;
    
    //test frame buffer
    GLuint defaultFramebuffer, colorRenderbuffer;
    
    GLint backWidth;
    GLint backHeight;
    
    dispatch_queue_t queue;
    
    int currentStage;
    
    BOOL wait_interaction;
    
    BOOL interrupt_lod_up;
    
    bool duringInteraction;
    
    float wait_time;
    GLuint textureName;
    
    BOOL while_interacting;
    
    BOOL _viewChanged;
    
}


@property (retain, atomic) EAGLContext *context;
@property (retain, atomic) GLKBaseEffect *effect;


- (void) setupGL;
- (void) tearDownGL;

@end

@implementation ProgMeshGLKViewController

@synthesize status = _status;
@synthesize current_lod;
@synthesize textureInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"View", @"View");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    
    progMeshGLManager = [[ProgMeshGLManager alloc] init];
    
    progMeshGLManager.duringVBOUpdating = false;
    
    [progMeshGLManager setUpdateInfo:NULL];
    
    _status = PM_VIEW_STATUS_NONE;
    
    _rotation.x = 0.0f;
    _rotation.y = 0.0f;
    
    translateX = 0.0f;
    translateY = 0.0f;
    
    baseModelViewMatrix = GLKMatrix4MakeTranslation(0 , 0, 0);
    
    current_lod = 0;
    
    queue = dispatch_queue_create("queue", NULL);
    
    currentStage = 0;
    
    wait_interaction = false;
    
    interrupt_lod_up = NO;
    
    duringInteraction = false;
    
    wait_time = 0.0f;
    
    while_interacting = NO;
    
    _viewChanged = NO;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [super setPreferredFramesPerSecond:60];
    
    //self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.context = [progMeshGLManager createEAGLContext];
    
    [[ProgMeshCentralController sharedInstance] setCurrentContext:self.context];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    
    [self.view setMultipleTouchEnabled:YES];
    
    progMeshGLManager.bounds = view.bounds;
    
    
    view.context = self.context;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self setupGL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}


- (void) setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [progMeshGLManager loadShaders:_program];
    
    self.effect = [progMeshGLManager createGLKBaseEffect];
    progMeshGLManager.layer = (CAEAGLLayer *)self.view.layer;
    
    glEnable(GL_DEPTH_TEST);
    
    
    float scenePosition[] = {0.0f, 0.0f, 0.0f, 1.0f};
    [self setScenePosition: scenePosition];
    
    _rotMatrix = GLKMatrix4Identity;
    _quat = GLKQuaternionMake(0, 0, 0, 1);
    _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    
    UITapGestureRecognizer * dtRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dtRec.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:dtRec];
    
    [EAGLContext setCurrentContext:self.context];
    
    [self loadTexture];
    [progMeshGLManager initServerRenderingBackgroundQuad];
    //[self loadTexture2];
}

- (BOOL) loadTexture
{
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    
    NSError * error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"texture.png" ofType:nil];
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (self.textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (BOOL) updateTexture : (NSData *) texData
{
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    
    NSError * error;
    if (textureInfo != nil) {
        GLuint name = textureInfo.name;
        glDeleteTextures(1, &name);
        [textureInfo release];
        textureInfo = nil;
    }
    self.textureInfo = [GLKTextureLoader textureWithContentsOfData:texData options:options error:&error];
    if (self.textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (void) loadTexture2
{
    CGImageRef spriteImage = [UIImage imageNamed:@"texture.png"].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", @"texture.png");
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    glGenTextures(1, &textureName);
    glBindTexture(GL_TEXTURE_2D, textureName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
}

- (void)tearDownGL
{
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

int count;

float objCenter[3];
float objRadius = 0;


float LOD[8] =  {0.001f, 2e-4f, 4e-5f, 8e-6f, 1.6e-6f, 3.2e-7f, 6.4e-8f, 1.28e-8};

#pragma mark - GLKView and GLKViewController delegate methods

#define UPDATE_INFO_TO_DELETE_EACH_TIME 100
#define EACH_PACKET_LENGTH  80

- (void)update
{
    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
        
        //use server rendering
        if(!while_interacting && !_viewChanged && [[ProgMeshCentralController sharedInstance] updateTexFinish]){
            [[ProgMeshCentralController sharedInstance] setUpdateTexFinish:NO];
            if(wait_interaction == false){
                wait_interaction = true;
                [NSTimer scheduledTimerWithTimeInterval:wait_time
                                                 target:self
                                               selector:@selector(lod_up_server_rendering)
                                               userInfo:nil
                                                repeats:NO];
                wait_time = 0.0f;
                
            }
            
        }
    } else{
        switch (_status) {
            case PM_VIEW_STATUS_NONE:
                //NSLog(@"PM_VIEW_STATUS_NONE");
                break;
                
            case PM_VIEW_STATUS_SPM_RENDER_BASE_MESH:
                //NSLog(@"PM_VIEW_STATUS_SPM_RENDER_BASE_MESH");
            {
                
                std::list<NSData *> * tempList = (std::list<NSData *> *)[[ProgMeshCentralController sharedInstance] get_update_data];
                
                if(tempList->size() > 0){
                    NSData * data = tempList->front();
                    [progMeshGLManager update_with_vsplits:data];
                    tempList->erase(tempList->begin());
                }
                
                
                if(tempList->size() == 0 && [[ProgMeshCentralController sharedInstance] subUpdateFinish] && !duringInteraction ){
                    [[ProgMeshCentralController sharedInstance] setSubUpdateFinish:NO];
                    if(wait_interaction == false){
                        wait_interaction = true;
                        [NSTimer scheduledTimerWithTimeInterval:wait_time
                                                         target:self
                                                       selector:@selector(lod_up)
                                                       userInfo:nil
                                                        repeats:NO];
                        wait_time = 0.0f;
                        
                    }
                    
                }
                
            }
                break;
            default:
                break;
        }
    }
}

int ccnt = 0;

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
        //server rendering
        if([[ProgMeshCentralController sharedInstance] textureDataUpdated]){
            [self updateTexture:[[ProgMeshCentralController sharedInstance] getDisplayTextureData]];
            [[ProgMeshCentralController sharedInstance] releaseDisplayTextureData];
            [[ProgMeshCentralController sharedInstance] setTextureDataUpdated:NO];
            _viewChanged = NO;
            [[ProgMeshCentralController sharedInstance] setUpdateTexFinish:YES];
        }
        if(!while_interacting && !_viewChanged){
            
            
            float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
            projectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1 / aspect, 1 / aspect, 0.01, 100.0f);
            self.effect.transform.projectionMatrix = projectionMatrix;
            
            GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -2);
            self.effect.transform.modelviewMatrix = modelViewMatrix;
            self.effect.texture2d0.name = self.textureInfo.name;
            self.effect.texture2d0.enabled = YES;
            [self.effect prepareToDraw];
            
            [progMeshGLManager drawServerRendering];
            
        }
        else{
            if (_increasing) {
                _curRed += 1.0 * self.timeSinceLastUpdate;
            } else {
                _curRed -= 1.0 * self.timeSinceLastUpdate;
            }
            if (_curRed >= 1.0) {
                _curRed = 1.0;
                _increasing = NO;
            }
            if (_curRed <= 0.0) {
                _curRed = 0.0;
                _increasing = YES;
            }
            
            float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
            projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.01 * objRadius, 100.0f * objRadius);
            self.effect.transform.projectionMatrix = projectionMatrix;
            
            if (_slerping) {
                
                _slerpCur += self.timeSinceLastUpdate;
                float slerpAmt = _slerpCur / _slerpMax;
                if (slerpAmt > 1.0) {
                    slerpAmt = 1.0;
                    _slerping = NO;
                }
                
                _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
            }
            [self setScenePosition:[progMeshModel getCentroidAndRadius] ];
            //[self setScenePosition:[progMeshModel get_final_centroid_radius] ];
            float * modelview_matrix_ = progMeshGLManager.modelViewMatrix.m;
            Vec3f t(modelview_matrix_[0]*objCenter[0] +
                    modelview_matrix_[4]*objCenter[1] +
                    modelview_matrix_[8]*objCenter[2] +
                    modelview_matrix_[12],
                    modelview_matrix_[1]*objCenter[0] +
                    modelview_matrix_[5]*objCenter[1] +
                    modelview_matrix_[9]*objCenter[2] +
                    modelview_matrix_[13],
                    modelview_matrix_[2]*objCenter[0] +
                    modelview_matrix_[6]*objCenter[1] +
                    modelview_matrix_[10]*objCenter[2] +
                    modelview_matrix_[14]);
            GLKMatrix4 modelViewMatrix = progMeshGLManager.modelViewMatrix;
            GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quat);
            GLKMatrix4 temp = GLKMatrix4MakeTranslation(0, 0, 0);
            temp = GLKMatrix4Translate(temp, t[0], t[1], t[2]);
            //translate
            temp = GLKMatrix4Translate(temp, -translateX * 0.0005 * objRadius, translateY * 0.0005 * objRadius, 0);
            //zoom
            temp = GLKMatrix4Translate(temp, 0, 0, zoomDistance * 0.001 * objRadius);
            
            temp = GLKMatrix4Multiply(temp, rotation);
            temp = GLKMatrix4Translate(temp, -t[0], -t[1], -t[2]);
            
            modelViewMatrix = GLKMatrix4Multiply(temp, modelViewMatrix);
            
            progMeshGLManager.modelViewMatrix = modelViewMatrix;
            
            progMeshGLManager.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
            progMeshGLManager.modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            _modelViewMatrix = modelViewMatrix;
            
            [progMeshGLManager draw2];

        }
    } else{
        switch (_status) {
            case PM_VIEW_STATUS_NONE:
            {
                //[EAGLContext setCurrentContext:self.context];
                
                //NSLog(@"Draw PM_VIEW_STATUS_NONE");
                break;
            }
            case PM_VIEW_STATUS_SPM_RENDER_BASE_MESH:
                //NSLog(@"Draw PM_VIEW_STATUS_SPM_RENDER_BASE_MESH");
                
                
            {
                if (_increasing) {
                    _curRed += 1.0 * self.timeSinceLastUpdate;
                } else {
                    _curRed -= 1.0 * self.timeSinceLastUpdate;
                }
                if (_curRed >= 1.0) {
                    _curRed = 1.0;
                    _increasing = NO;
                }
                if (_curRed <= 0.0) {
                    _curRed = 0.0;
                    _increasing = YES;
                }
                
                float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
                projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.01 * objRadius, 100.0f * objRadius);
                self.effect.transform.projectionMatrix = projectionMatrix;
                
                if (_slerping) {
                    
                    _slerpCur += self.timeSinceLastUpdate;
                    float slerpAmt = _slerpCur / _slerpMax;
                    if (slerpAmt > 1.0) {
                        slerpAmt = 1.0;
                        _slerping = NO;
                    }
                    
                    _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
                }
                [self setScenePosition:[progMeshModel getCentroidAndRadius] ];
                float * modelview_matrix_ = progMeshGLManager.modelViewMatrix.m;
                Vec3f t(modelview_matrix_[0]*objCenter[0] +
                        modelview_matrix_[4]*objCenter[1] +
                        modelview_matrix_[8]*objCenter[2] +
                        modelview_matrix_[12],
                        modelview_matrix_[1]*objCenter[0] +
                        modelview_matrix_[5]*objCenter[1] +
                        modelview_matrix_[9]*objCenter[2] +
                        modelview_matrix_[13],
                        modelview_matrix_[2]*objCenter[0] +
                        modelview_matrix_[6]*objCenter[1] +
                        modelview_matrix_[10]*objCenter[2] +
                        modelview_matrix_[14]);
                GLKMatrix4 modelViewMatrix = progMeshGLManager.modelViewMatrix;
                GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quat);
                GLKMatrix4 temp = GLKMatrix4MakeTranslation(0, 0, 0);
                temp = GLKMatrix4Translate(temp, t[0], t[1], t[2]);
                //translate
                temp = GLKMatrix4Translate(temp, -translateX * 0.0005 * objRadius, translateY * 0.0005 * objRadius, 0);
                //zoom
                temp = GLKMatrix4Translate(temp, 0, 0, zoomDistance * 0.001 * objRadius);
                
                temp = GLKMatrix4Multiply(temp, rotation);
                temp = GLKMatrix4Translate(temp, -t[0], -t[1], -t[2]);
                
                modelViewMatrix = GLKMatrix4Multiply(temp, modelViewMatrix);
                
                progMeshGLManager.modelViewMatrix = modelViewMatrix;
                
                progMeshGLManager.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
                progMeshGLManager.modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
                _modelViewMatrix = modelViewMatrix;
                
                [progMeshGLManager draw2];
                //[progMeshGLManager drawServerRendering];
                
                [self.view setUserInteractionEnabled:YES];
                
                break;
            }
            default:
                break;
        }
    }
    
    
}

- (void) setProgMeshGLManager : (ProgMeshGLManager *) pmglManager
{
    progMeshGLManager = pmglManager;
}

- (ProgMeshGLManager *) getProgMeshGLManager
{
    return progMeshGLManager;
}

- (void) setProgMeshModel : (ProgMeshModel *) pmModel
{
    progMeshModel = pmModel;
}

- (ProgMeshModel *) getProgMeshModel
{
    return progMeshModel;
}


- (void) setScenePosition : (float *) centroidAndRadius
{
    
    objCenter[0] = centroidAndRadius[0];
    objCenter[1] = centroidAndRadius[1];
    objCenter[2] = centroidAndRadius[2];
    
    objRadius = centroidAndRadius[3];
    progMeshGLManager.modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, 0);
    float *modelview_matrix_ = progMeshGLManager.modelViewMatrix.m;
    progMeshGLManager.modelViewMatrix =
    GLKMatrix4Translate(progMeshGLManager.modelViewMatrix,
                        -(modelview_matrix_[0]*objCenter[0] +
                          modelview_matrix_[4]*objCenter[1] +
                          modelview_matrix_[8]*objCenter[2] +
                          modelview_matrix_[12]),
                        -(modelview_matrix_[1]*objCenter[0] +
                          modelview_matrix_[5]*objCenter[1] +
                          modelview_matrix_[9]*objCenter[2] +
                          modelview_matrix_[13]),
                        -(modelview_matrix_[2]*objCenter[0] +
                          modelview_matrix_[6]*objCenter[1] +
                          modelview_matrix_[10]*objCenter[2] +
                          modelview_matrix_[14] +
                          3.0*objRadius) );
    
}

void printMatrix4(GLKMatrix4 * m){
    NSLog(@"%f, %f, %f, %f", m->m00, m->m01, m->m02, m->m03 );
    NSLog(@"%f, %f, %f, %f", m->m10, m->m11, m->m12, m->m13 );
    NSLog(@"%f, %f, %f, %f", m->m20, m->m21, m->m22, m->m23 );
    NSLog(@"%f, %f, %f, %f", m->m30, m->m31, m->m32, m->m33 );
}


- (GLKVector3) projectOntoSurface:(GLKVector3) touchPoint
{
    float radius = self.view.bounds.size.width/3;
    GLKVector3 center = GLKVector3Make(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0);
    GLKVector3 P = GLKVector3Subtract(touchPoint, center);
    
    // Flip the y-axis because pixel coords increase toward the bottom.
    P = GLKVector3Make(P.x, P.y * -1, P.z);
    
    float radius2 = radius * radius;
    float length2 = P.x*P.x + P.y*P.y;
    
    if (length2 <= radius2)
        P.z = sqrt(radius2 - length2);
    else
    {
        P.z = radius2 / (2.0 * sqrt(length2));
        float length = sqrt(length2 + P.z * P.z);
        P = GLKVector3DivideScalar(P, length);
    }
    
    return GLKVector3Normalize(P);
}

- (void)computeIncremental {
    
    GLKVector3 axis = GLKVector3CrossProduct(_anchor_position, _current_position);
    float dot = GLKVector3DotProduct(_anchor_position, _current_position);
    float angle = acosf(dot);
    
    GLKQuaternion Q_rot = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis);
    Q_rot = GLKQuaternionNormalize(Q_rot);
    
    // TODO: Do something with Q_rot...
    _quat = GLKQuaternionMultiply(Q_rot, _quatStart);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
        if([[ProgMeshCentralController sharedInstance] getSocketHandler]._SOCKET_STATE == SOCKET_CONNECTED_IDLE){
            
            NSArray *allTouches = [[event allTouches] allObjects];
            
            if ([allTouches count] == 1) {
                
                
                UITouch * touch = [allTouches objectAtIndex:0];
                CGPoint location = [touch locationInView:self.view];
                
                _anchor_position = GLKVector3Make(location.x, location.y, 0);
                _current_position = _anchor_position;

                _anchor_position = [self projectOntoSurface:_anchor_position];
                
                _quatStart = _quat;
                
                interrupt_lod_up = YES;
            } else if ([allTouches count] == 2)
            {
                //do nothing
                
            }
        }
    } else{
        if([[ProgMeshCentralController sharedInstance] getSocketHandler]._SOCKET_STATE == SOCKET_CONNECTED_IDLE){
            
            NSArray *allTouches = [[event allTouches] allObjects];
            
            if ([allTouches count] == 1) {
                
                
                UITouch * touch = [allTouches objectAtIndex:0];
                CGPoint location = [touch locationInView:self.view];
                
                _anchor_position = GLKVector3Make(location.x, location.y, 0);
                _current_position = _anchor_position;

                _anchor_position = [self projectOntoSurface:_anchor_position];
                
                _quatStart = _quat;
                
                interrupt_lod_up = YES;
            } else if ([allTouches count] == 2)
            {
                //do nothing
                
            }
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
//        while_interacting = NO;
//    }else{
    while_interacting = NO;
        NSLog(@"vfront: %d",[(VDPMModel *) progMeshModel get_vfront_size]);
        if([[ProgMeshCentralController sharedInstance] getSocketHandler]._SOCKET_STATE == SOCKET_CONNECTED_IDLE){
            NSArray *allTouches = [[event allTouches] allObjects];
            
            if ([allTouches count] == 1) {
                NSLog(@"1 finger ends");
                [(VDPMModel *)progMeshModel update_viewing_parameters:_modelViewMatrix :fabsf(self.view.bounds.size.width / self.view.bounds.size.height) :45];
                
            } else if ([allTouches count] == 2)
            {
                [(VDPMModel *)progMeshModel update_viewing_parameters: _modelViewMatrix :fabsf(self.view.bounds.size.width / self.view.bounds.size.height) :45];
                NSLog(@"2 finger ends");
                
            }
            if([[ProgMeshCentralController sharedInstance] isServerRendering]){
                if([[ProgMeshCentralController sharedInstance] textureDataUpdated])
                    [[ProgMeshCentralController sharedInstance] setTextureDataUpdated:NO];
                _viewChanged = YES;
                duringInteraction = false;
                [self lod_up_server_rendering];

            } else {
                duringInteraction = false;
                [self lod_up];
            }
        }
        
        duringInteraction = false;
        
    //}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
//        while_interacting = YES;
//
//    } else{
        while_interacting = YES;
        duringInteraction = true;
        
        wait_time = 0.5f;
        
        NSArray *allTouches = [[event allTouches] allObjects];
        
        if ([allTouches count] == 1) {
            currentStage = 0;
            UITouch * touch = [allTouches objectAtIndex:0];
            CGPoint location = [touch locationInView:self.view];
            CGPoint lastLoc = [touch previousLocationInView:self.view];
            CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
            
            
            if(![[ProgMeshCentralController sharedInstance] getClientAbort] && location.y > 100 && [[ProgMeshCentralController sharedInstance] isDuringUpdating])
            {
                
                NSLog(@"Abort!");
                [[ProgMeshCentralController sharedInstance] setClientAbort:true];
            }
            
            
            float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
            float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
            
            bool isInvertible;
            GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
            GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0));
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
            
            _current_position = GLKVector3Make(location.x, location.y, 0);
            _current_position = [self projectOntoSurface:_current_position];
            
            [self computeIncremental];
            
        } else if ([allTouches count] == 2){
            currentStage = 0;

            if(![[ProgMeshCentralController sharedInstance] getClientAbort] && [[ProgMeshCentralController sharedInstance] isDuringUpdating])
            {
                
                NSLog(@"Abort!");
                [[ProgMeshCentralController sharedInstance] setClientAbort:true];
            }
            
            UITouch *touchA = [allTouches objectAtIndex:0];
            UITouch *touchB = [allTouches objectAtIndex:1];
            
            CGPoint pointA_ = [touchA locationInView:self.view];
            CGPoint pointA = [touchA previousLocationInView:self.view];
            
            CGPoint pointB_ = [touchB locationInView:self.view];
            CGPoint pointB = [touchB previousLocationInView:self.view];
            
            float disA_B_Now = sqrtf(((pointA_.x - pointB_.x) * (pointA_.x - pointB_.x) + (pointA_.y - pointB_.y) * (pointA_.y - pointB_.y)));
            float disAB_Previous = sqrtf((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y));
            
            zoomDistance += disA_B_Now - disAB_Previous;
            
            translateX += (pointA.x + pointB.x) / 2 - (pointA_.x + pointB_.x) / 2;
            translateY += (pointA.y + pointB.y) / 2 - (pointA_.y + pointB_.y) / 2;
            
            
        } 
        
    //}
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
        
    } else{
        _slerping = YES;
        _slerpCur = 0;
        _slerpMax = 1.0;
        _slerpStart = _quat;
        _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
    }
}


- (void)dealloc {
    [_progress release];
    [super dealloc];
}
- (IBAction)decrease_screen_error:(id)sender {
    if ([[ProgMeshCentralController sharedInstance] isServerRendering]) {
        [self lod_up_server_rendering];
    } else{
        [self lod_up];
    }
    
    
}

- (void) resetCurrentStage
{
    @synchronized(self){
        currentStage = 0;
    }
}

- (int) getSuitableStage
{
    while (currentStage < 100) {
        
        [(VDPMModel *) progMeshModel set_tolerance_square:(10 * pow(2, currentStage))];
        if([(VDPMModel *) progMeshModel get_require_n_refinement]){
            break;
        }
        currentStage ++;
    }
    return currentStage;
}

- (void) lod_up_server_rendering
{
    if(duringInteraction)
        return;
    //[(VDPMModel *) progMeshModel decrease_tolerance_square];
    [(VDPMModel *) progMeshModel set_tolerance_square:(pow(5, currentStage ++))];
    [(VDPMModel *)progMeshModel update_viewing_parameters:_modelViewMatrix :fabsf(self.view.bounds.size.width / self.view.bounds.size.height) :45];
    
    //update viewing parameters with server
    if([[ProgMeshCentralController sharedInstance] getSocketHandler]._SOCKET_STATE == SOCKET_CONNECTED_IDLE)
        [[ProgMeshCentralController sharedInstance] syncViewingParametersToServer:[(VDPMModel *)progMeshModel getViewingParameters]];
    
    wait_interaction = false;
}

- (void) lod_up
{
    if(duringInteraction)
        return;
    
    [(VDPMModel *) progMeshModel set_tolerance_square:(pow(5, currentStage ++))];
    [(VDPMModel *)progMeshModel update_viewing_parameters:_modelViewMatrix :fabsf(self.view.bounds.size.width / self.view.bounds.size.height) :45];
    if(![((VDPMModel *) progMeshModel) get_require_n_refinement]){
        wait_interaction = false;
        return;
    }
        //update viewing parameters with server
    if([[ProgMeshCentralController sharedInstance] getSocketHandler]._SOCKET_STATE == SOCKET_CONNECTED_IDLE)
        [[ProgMeshCentralController sharedInstance] syncViewingParametersToServer:[(VDPMModel *)progMeshModel getViewingParameters]];
    
    wait_interaction = false;
    
}
@end
