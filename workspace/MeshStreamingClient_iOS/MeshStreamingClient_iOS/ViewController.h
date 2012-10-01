//
//  ViewController.h
//  iOSSocketSample
//
//  Created by Xu Haiyang on 9/25/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface ViewController : UIViewController<GCDAsyncSocketDelegate,UITextFieldDelegate>{
    GCDAsyncSocket *socket;
}

@property NSInteger STATE;
@property NSInteger NBaseVertices;
@property NSInteger NBaseFaces;
@property NSInteger NDetailVertices;
@property NSInteger NMaxVertices;
@property NSInteger SizeBaseMesh;
@property NSData*   BaseMeshChunk;
@property NSInteger TransmittedDetails;
@property float     TransmitProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;

@property(strong)  GCDAsyncSocket *socket;

@property (strong, nonatomic) IBOutlet UITextView *append;
- (IBAction)connect:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *host;
//@property (strong, nonatomic) IBOutlet UITextView *output;
@property (strong, nonatomic) IBOutlet UITextField *port;

@end
