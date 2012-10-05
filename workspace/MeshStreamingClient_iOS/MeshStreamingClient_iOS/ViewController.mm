//
//  ViewController.m
//  iOSSocketSample
//
//  Created by Xu Haiyang on 9/25/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ViewController.h"
/*
 @interface ViewController ()
 
 @end
 */
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
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory Warning Received!");
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


@end
