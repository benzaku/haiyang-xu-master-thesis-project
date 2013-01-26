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
    
    //test frame buffer
    GLuint defaultFramebuffer, colorRenderbuffer;

    GLint backWidth;
    GLint backHeight;

}


@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;


- (void) setupGL;
- (void) tearDownGL;

@end

@implementation ProgMeshGLKViewController

@synthesize status = _status;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"View", @"View");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    
    progMeshGLManager = [[ProgMeshGLManager alloc] init];
    
    _status = PM_VIEW_STATUS_NONE;
    
    _rotation.x = 0.0f;
    _rotation.y = 0.0f;
    
    baseModelViewMatrix = GLKMatrix4MakeTranslation(0 , 0, 0);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [super setPreferredFramesPerSecond:60];
    
    //self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.context = [progMeshGLManager createEAGLContext];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    
    [self.view setMultipleTouchEnabled:YES];
    
    view.context = self.context;
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
        
    //self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    
    float scenePosition[] = {0.0f, 0.0f, 0.0f, 1.0f};
    [self setScenePosition: scenePosition];
    
    _rotMatrix = GLKMatrix4Identity;
    _quat = GLKQuaternionMake(0, 0, 0, 1);
    _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    
    UITapGestureRecognizer * dtRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dtRec.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:dtRec];

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

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
        
    switch (_status) {
        case PM_VIEW_STATUS_NONE:
            //NSLog(@"PM_VIEW_STATUS_NONE");
            break;
            
        case PM_VIEW_STATUS_SPM_RENDER_BASE_MESH:
            //NSLog(@"PM_VIEW_STATUS_SPM_RENDER_BASE_MESH");
        {
            //[(VDPMModel *)progMeshModel adaptive_refinement];

        }
            break;
            
        default:
            break;
    }
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
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
            
            float d = zoomDistance / 120 * 0.2 * objRadius;
            
            GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(objCenter[0], objCenter[1], objCenter[2] - 3 * objRadius + d);
            
            GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quat);
            modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotation);
            
            
            modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, -objCenter[0] , -objCenter[1] , -objCenter[2]);
            
            GLKMatrix4 transM = GLKMatrix4MakeTranslation(-objCenter[0] , -objCenter[1] , -objCenter[2]);
            
            modelViewMatrix = GLKMatrix4Multiply(transM, modelViewMatrix);
            
            //self.effect.transform.modelviewMatrix = modelViewMatrix;
            
            
            
            progMeshGLManager.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
            progMeshGLManager.modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            //[progMeshGLManager draw:self.effect];
                
            
            [progMeshGLManager draw2];
           
            break;
        }
        default:
            break;
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
        /*
         P.x *= radius / sqrt(length2);
         P.y *= radius / sqrt(length2);
         P.z = 0;
         */
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
    
    NSArray *allTouches = [[event allTouches] allObjects];

    if ([allTouches count] == 1) {
        
        
        UITouch * touch = [allTouches objectAtIndex:0];
        CGPoint location = [touch locationInView:self.view];
        
        _anchor_position = GLKVector3Make(location.x, location.y, 0);
        _anchor_position = [self projectOntoSurface:_anchor_position];
        
        _current_position = _anchor_position;
        _quatStart = _quat;
    } else if ([allTouches count] == 2)
    {
        //do nothing
        
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [[event allTouches] allObjects];
    
    if ([allTouches count] == 1) {
        NSLog(@"1 finger ends");
        
        [(VDPMModel *)progMeshModel update_viewing_parameters:progMeshGLManager.modelViewProjectionMatrix :fabsf(self.view.bounds.size.width / self.view.bounds.size.height) :45];
        //update viewing parameters with server
        
        [[ProgMeshCentralController sharedInstance] syncViewingParametersToServer:[(VDPMModel *)progMeshModel getViewingParameters]];
        
    } else if ([allTouches count] == 2)
    {
        [(VDPMModel *)progMeshModel update_viewing_parameters:progMeshGLManager.modelViewProjectionMatrix :fabsf(self.view.bounds.size.width / self.view.bounds.size.height) :45];
        NSLog(@"2 finger ends");

        //do nothing
        
    }

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *allTouches = [[event allTouches] allObjects];
    
    if ([allTouches count] == 1) {
        
        UITouch * touch = [allTouches objectAtIndex:0];
        CGPoint location = [touch locationInView:self.view];
        CGPoint lastLoc = [touch previousLocationInView:self.view];
        CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
        
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
        UITouch *touchA = [allTouches objectAtIndex:0];
        UITouch *touchB = [allTouches objectAtIndex:1];
        
        CGPoint pointA_ = [touchA locationInView:self.view];
        CGPoint pointA = [touchA previousLocationInView:self.view];
        
        CGPoint pointB_ = [touchB locationInView:self.view];
        CGPoint pointB = [touchB previousLocationInView:self.view];
        
        float disA_B_Now = sqrtf(((pointA_.x - pointB_.x) * (pointA_.x - pointB_.x) + (pointA_.y - pointB_.y) * (pointA_.y - pointB_.y)));
        float disAB_Previous = sqrtf((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y));
        
        zoomDistance += disA_B_Now - disAB_Previous;
        
    }
    
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    _slerping = YES;
    _slerpCur = 0;
    _slerpMax = 1.0;
    _slerpStart = _quat;
    _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
    
}


@end
