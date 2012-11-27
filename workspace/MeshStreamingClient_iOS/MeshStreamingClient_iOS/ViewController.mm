//
//  ViewController.m
//  iOSSocketSample
//
//  Created by Xu Haiyang on 9/25/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ViewController.h"
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};



GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


GLfloat gCubeVertexData2[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    1.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    1.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    1.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    1.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    1.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    1.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};



@interface ViewController (){
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _myFence;
    
    GLuint _vertexNormalBufferVBO;
    GLuint _faceIndiceBufferIBO;
    
    // cur;
    int cur;
    
    int currentRecoveredFace;
    
    
    float objCenter[3];
    float objRadius;
    
    GLKVector3 _anchor_position;
    GLKVector3 _current_position;
    GLKQuaternion _quatStart;
    GLKQuaternion _quat;
    
    GLKMatrix4 _rotMatrix;
    
    BOOL _slerping;
    float _slerpCur;
    float _slerpMax;
    GLKQuaternion _slerpStart;
    GLKQuaternion _slerpEnd;
    
    
    // temp
    GLuint _cubeBuffer;
    
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;


- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
 
@end

@implementation ViewController

@synthesize socket;
@synthesize host;
@synthesize port;
@synthesize progress;
@synthesize detailRecoverProgress;

@synthesize STATE;
@synthesize NBaseVertices;
@synthesize NBaseFaces;
@synthesize NDetailVertices;
@synthesize NMaxVertices;
@synthesize SizeBaseMesh;
@synthesize BaseMeshChunk;
@synthesize TransmittedDetails;
@synthesize TransmitProgress;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pmModel = [[ProgressiveMeshModel alloc] init];
    BaseMeshBuf = NULL;
    BaseMeshBufPointer = 0;
    
    //GL load
    
    [super setPreferredFramesPerSecond:60];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    
    [self.view setMultipleTouchEnabled:YES];
    
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    objCenter[0] = 0, objCenter[1] = 0; objCenter[2] = 0;
    objRadius = 1.0f;
    
    cur = 0;
    currentRecoveredFace = 0;
    
    [self setupGL];

    
}

- (void) dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}



- (IBAction)connect:(id)sender {
    
    [socket disconnect];
    [progress setProgress:0];
    
    [detailRecoverProgress setProgress:0];
    
    NSLog(@"Connect Clicked!");
    NSLog(@"host = %@", host.text);
    NSLog(@"port = %@", port.text);
    
    socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if(![socket connectToHost:host.text onPort:[port.text intValue] error:&err])
    {
        //[self addText:err.description];
        NSLog(err.description);
    }else
    {
        NSLog(@"ok");
        NSLog(@"socket connected!");
        //output.text = [output.text stringByAppendingFormat:@"%@\n",@"Socket Connected!"];
    }
    
    currentRecoveredFace = 0;
    [pmModel clear];
    pmModel = [[ProgressiveMeshModel alloc] init];
    objCenter[0] = 0, objCenter[1] = 0; objCenter[2] = 0;
    objRadius = 1.0f;
    
    //[self setupGL];
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //[self addText:[NSString stringWithFormat:@"连接到:%@",host]];
    STATE = 0;
    NBaseFaces = 0;
    NBaseVertices = 0;
    NDetailVertices = 0;
    NMaxVertices = 0;
    SizeBaseMesh = 0;
    TransmittedDetails = 0;
    TransmitProgress = 0;
    NSLog(@"connected to: %@", host);
    [socket readDataWithTimeout:-1 tag:0];
    
}




-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receivedStringMessage;
    NSString *requestString;
    size_t receivedSizeT;
    NSComparisonResult compareResult;
    int nByteToWait;
    switch (STATE) {
        case 0:
            //state 0 denotes initial state. should receive HELLO
            receivedStringMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            compareResult = [receivedStringMessage compare:@"HELLO"];
            if(compareResult == NSOrderedSame){
                NSLog(@"\"%@\" Received,Size = %u, go to stage 1", receivedStringMessage, receivedStringMessage.length);
                STATE = 1;
                
                requestString = @"N_BASE_VERTICES";
                [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                [socket readDataWithTimeout:-1 tag:0];
            }
            break;
            
        case 1:
            //state 1 denotes "N_BASE_VERTICES" sent .  now should reveice an size_t
            
            [data getBytes: &receivedSizeT length: sizeof(size_t)];
            NSLog(@"N_BASE_VERTICES = %zu", receivedSizeT);
            [pmModel setNBaseVertices:receivedSizeT];
            [pmModel setNVertices:receivedSizeT];
            NBaseVertices = receivedSizeT;
            STATE = 2;
            
            requestString = @"N_BASE_FACES";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [socket readDataWithTimeout:-1 tag:0];
            break;
            
        case 2:
            //state 2 denotes "N_BASE_FACES" sent .  now should reveice an size_t
            [data getBytes: &receivedSizeT length: sizeof(size_t)];
            NSLog(@"N_BASE_FACES = %zu", receivedSizeT);
            [pmModel setNBaseFaces:receivedSizeT];
            [pmModel setNFaces:receivedSizeT];
            NBaseFaces = receivedSizeT;
            STATE = 3;
            
            requestString = @"N_DETAIL_VERTICES";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [socket readDataWithTimeout:-1 tag:0];
            
            break;
        case 3:
            //state 3 denotes "N_DETAIL_VERTICES" sent .  now should reveice an size_t
            [data getBytes: &receivedSizeT length: sizeof(size_t)];
            NSLog(@"N_DETAIL_VERTICES = %zu", receivedSizeT);
            [pmModel setNDetailVertices:receivedSizeT];
            NDetailVertices = receivedSizeT;
            STATE = 4;
            
            requestString = @"N_MAX_VERTICES";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [socket readDataWithTimeout:-1 tag:0];
            
            break;
        case 4:
            //state 4 denotes "N_MAX_VERTICES" sent .  now should reveice an size_t
            [data getBytes: &receivedSizeT length: sizeof(size_t)];
            NSLog(@"N_MAX_VERTICES = %zu", receivedSizeT);
            [pmModel setNMaxVertices:receivedSizeT];
            NMaxVertices = receivedSizeT;
            STATE = 5;
            
            requestString = @"BASE_MESH";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [socket readDataWithTimeout:-1 tag:0];
            
            break;
            
        case 5:
            //state 5 denotes "N_MAX_VERTICES" sent .  now should reveice an size_t
            [data getBytes: &receivedSizeT length: sizeof(size_t)];
            NSLog(@"SIZE_OF_BASE_MESH = %zu", receivedSizeT);
            [pmModel setSizeBaseMesh:receivedSizeT];
            SizeBaseMesh = receivedSizeT;
            
            BaseMeshBuf = new char[[pmModel sizeBaseMesh]];
            BaseMeshBufPointer = 0;
            STATE = 6;
            
            requestString = @"ACK_OK_SIZE_OF_BASE_MESH";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [socket readDataWithTimeout:-1 tag:0];
            
            break;
            
        case 6:
            //state 6 denotes "ACK_OK_SIZE_OF_BASE_MESH" sent .  now should reveice a data chunk of BaseMesh
            NSLog(@"Size of Base Mesh: %u", data.length);
            
            NSLog(@"Save data in Buf");
            [data getBytes:BaseMeshBuf + BaseMeshBufPointer length:data.length];
            BaseMeshBufPointer += data.length;
            NSLog(@"basemeshbuffer = %d, sizebasemesh = %d", BaseMeshBufPointer, [pmModel sizeBaseMesh]);
            if(BaseMeshBufPointer >= [pmModel sizeBaseMesh]){
                NSLog(@"Base Mesh transmitted!");
                [pmModel setBaseMeshChunk:[[NSData alloc] initWithBytes:BaseMeshBuf length:[pmModel sizeBaseMesh]]];
                objCenter[0] = [pmModel center][0], objCenter[1] = [pmModel center][1], objCenter[2] = [pmModel center][2];
                objRadius = [pmModel radius];
                STATE = 7;
                requestString = @"ACK_OK_BASE_MESH";
                [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                
                //release buf
                delete[] BaseMeshBuf;
                BaseMeshBufPointer = 0;
                [self updateBaseMeshToView];
            }
            
            [socket readDataWithTimeout:-1 tag:0];
                      
            
            
            break;
            
        case 7:
            //state 7 denotes "ACK_OK_BASE_MESH" sent .  now should reveice a data chunk of BaseMesh
            receivedStringMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            compareResult = [receivedStringMessage compare:@"PROGRESSIVE_DETAILS_READY"];
            if(compareResult == NSOrderedSame){
                NSLog(@"\"%@\" Received,Size = %u, go to stage 8", receivedStringMessage, receivedStringMessage.length);
                STATE = 8;
                
                requestString = @"PMDETAIL";
                [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                [socket readDataToLength:2400 withTimeout:-1 tag:0];
            }
            
            break;
        case 8:
            
            [pmModel addPMDetailsFromNSData:data];
            
            TransmittedDetails += data.length;
            
            TransmitProgress = ((float)TransmittedDetails) / ((float) NDetailVertices * 24);
            
            [progress setProgress:TransmitProgress];
            if(TransmitProgress >= 1){
                NSLog(@"Transmitted Progress : %d %", (int)(TransmitProgress * 100));
                //[pmModel refine:400];
                [socket disconnect];
            }
            
            
            
            //[socket readDataWithTimeout:-1 tag:0];
            
            nByteToWait = NDetailVertices * 24 - TransmittedDetails;
            if(nByteToWait > 2400)
                nByteToWait = 2400;
            [socket readDataToLength:nByteToWait withTimeout:-1 tag:0];
            
             break;
            
        default:
            break;
    }
    
    
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glBindVertexArrayOES(0);
    
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

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [self doRefinement];
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 10000.0f);
    
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
    
    
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(-objCenter[0] , -objCenter[1] , -objCenter[2] - objRadius * 5);
    
    GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quat);
    
    baseModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, rotation);
    
    
    
    
    self.effect.transform.modelviewMatrix = baseModelViewMatrix;
    
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
    
    if([touches count] == 1){
        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        
        _anchor_position = GLKVector3Make(location.x, location.y, 0);
        _anchor_position = [self projectOntoSurface:_anchor_position];
        
        _current_position = _anchor_position;
        _quatStart = _quat;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([touches count] == 1){
        UITouch * touch = [touches anyObject];
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
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    _slerping = YES;
    _slerpCur = 0;
    _slerpMax = 1.0;
    _slerpStart = _quat;
    _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
    
}


- (void) doRefinement
{
    int ooffset;
    int ssize;
    
    //determin refine steps
    if([pmModel getCurrentPointer] < [pmModel getDetailSize] && [pmModel getBaseMeshVertexNormalArraySize] != 0){
        
        if([pmModel getDetailSize] - [pmModel getCurrentPointer] > 25){
            [self refinement:25 :ooffset:ssize];
        }
        
        else if([pmModel getDetailSize] == [pmModel nDetailVertices]){
            [self refinement:[pmModel getDetailSize] - [pmModel getCurrentPointer] :ooffset :ssize];
        }
        
        [detailRecoverProgress setProgress:(float)([pmModel getCurrentPointer]) / (float)([pmModel nDetailVertices])];
        
        //update center and radius
        objCenter[0] = [pmModel center][0], objCenter[1] = [pmModel center][1], objCenter[2] = [pmModel center][2];
        objRadius = [pmModel radius];
        
    }
}

- (void) refinement: (int) steps: (int &) offset : (int &) size
{
    UpdateInfo *ui = [pmModel refineWithOffset:steps :offset :size];
    [self updateRefinementToView:offset :size : ui];
}

- (void) updateRefinementToView: (int)offset :(int)size : (UpdateInfo *) ui
{
        
    UpdatePartIndex * upi_array = ui->first;
    UpdatePartIndex * upi_indice = ui->second;
    
    for (UpdatePartIndex::iterator i = upi_array->begin(); i != upi_array->end(); i ++) {
        glBufferSubData(GL_ARRAY_BUFFER, (*i) * sizeof(float), 3 * sizeof(float), &[pmModel getBaseMeshVertexNormalArray][*i]);
    }
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    //update index
    
    
    // allocate enough space for indice vbo
    GLubyte * indice = (GLubyte *)&([pmModel getMeshIndiceArray][0]);
    currentRecoveredFace = [pmModel getCurrentRecoveredFacesNumber];
    
    for (UpdatePartIndex::iterator i = upi_indice->begin(); i != upi_indice->end(); i ++) {
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, (*i) * sizeof(unsigned int), 3 * sizeof(unsigned int), &[pmModel getMeshIndiceArray][*i]);
    }
    
    
}

- (void) updateBaseMeshToView
{
        
    /**** use draw elements ***/
    GLubyte * data = (GLubyte *)[pmModel getBaseMeshVertexNormalArray];
    
    GLsizei size = [pmModel getBaseMeshVertexNormalArraySize] * sizeof(float);
    
    glDeleteBuffers(1, &_vertexBuffer);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [pmModel getTotalVertexNormalArraySize] * sizeof(float), 0, GL_DYNAMIC_DRAW);
    
    GLvoid * vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    //transfer the vertex data to the vbo
    memcpy(vbo_buffer, data, size);
    
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    
    glGenBuffers(1, &_faceIndiceBufferIBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _faceIndiceBufferIBO);
    
    // allocate enough space for indice vbo
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [pmModel getTotalFaceIndiceBufferSize], 0, GL_STREAM_DRAW);
    // allocate model + cube: 
    
    //map indice buffer
    GLvoid * ibo_buffer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(ibo_buffer, [pmModel getMeshIndiceArray], [pmModel getBaseMeshIndiceBufferSize]);
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    /*** use draw elements end ***/

        
    
}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _faceIndiceBufferIBO);
    
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    if([pmModel getBaseMeshVertexNormalArraySize] == 0)
        glDrawArrays(GL_TRIANGLES, 0, 36);
    else{
        glDrawElements(GL_TRIANGLES, currentRecoveredFace * 3 , GL_UNSIGNED_INT, 0);
    }
    
    
   
}


#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
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
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
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
        
        return NO;
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
    
    return YES;
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}



@end
