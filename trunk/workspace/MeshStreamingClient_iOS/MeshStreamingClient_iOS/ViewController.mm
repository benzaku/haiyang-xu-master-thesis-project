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




@interface ViewController (){
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
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
    
    //GL load
    
    [super setPreferredFramesPerSecond:60];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    
    
    
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
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
            STATE = 6;
            
            requestString = @"ACK_OK_SIZE_OF_BASE_MESH";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [socket readDataWithTimeout:-1 tag:0];
            
            break;
            
        case 6:
            //state 6 denotes "ACK_OK_SIZE_OF_BASE_MESH" sent .  now should reveice a data chunk of BaseMesh
            NSLog(@"Size of Base Mesh: %u", data.length);
            [pmModel setBaseMeshChunk:data];
            BaseMeshChunk = [[NSData alloc] initWithData:data];
            NSLog(@"Size of newly allocated base mesh : %u", BaseMeshChunk.length);
            STATE = 7;
            requestString = @"ACK_OK_BASE_MESH";
            [socket writeData:[requestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
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
                //[socket readDataToLength:24 withTimeout:-1 tag:0];
                [socket readDataWithTimeout:-1 tag:0];
            }
            
            break;
        case 8:
            NSLog(@"data length : %u", data.length);
            NSLog(@"number of details transmitted in this packet = %u", data.length / 24);
            
            [pmModel addPMDetailsFromNSData:data];
            
            TransmittedDetails += data.length;
            
            TransmitProgress = ((float)TransmittedDetails) / ((float) NDetailVertices * 24);
            NSLog(@"TransmittedProgress:%f%", TransmitProgress * 100 );
            
            [progress setProgress:TransmitProgress];
            if(TransmitProgress >= 1){
                [socket disconnect];
            }
            [socket readDataWithTimeout:-1 tag:0];
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
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
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
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.1f;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
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
