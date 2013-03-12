//
//  ConfigViewController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/27/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ConfigViewController.h"

#import "Constants.h"

#import "AppDelegate.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

//@synthesize progMeshCentralController = _progMeshCentralController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Configuration", @"Configuration");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_serverHost setText:DEFAULT_HOST];
    [_serverPort setText:DEFAULT_PORT];
    
    ProgMeshCentralController *_progMeshCentralController = [ProgMeshCentralController sharedInstance];
    
    if(_progMeshCentralController == nil){
        _statusBar.backgroundColor = [UIColor redColor];
    }
    
    if([_progMeshCentralController isServerConnected]){
        _statusBar.backgroundColor = [UIColor greenColor];
        _statusBar.text = SERVER_STATE_CONNECTED;
        _connectButton.titleLabel.text = BUTTON_TEXT_DISCONNECT;
    } else{
        _statusBar.backgroundColor = [UIColor redColor];
        _statusBar.text = SERVER_STATE_NOT_CONNECTED;
        _connectButton.titleLabel.text = BUTTON_TEXT_CONNECT;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_serverHost release];
    [_serverPort release];
    [_statusBar release];
    [_connectButton release];
    [super dealloc];
}
- (IBAction)serverConnect:(UIButton *)sender {
    
    
    
    ProgMeshCentralController *_progMeshCentralController = nil;
    if(_progMeshCentralController == nil){
        _progMeshCentralController = [ProgMeshCentralController sharedInstance];
    }
    
    if(_progMeshCentralController != nil){
                
        [_progMeshCentralController getSocketHandler].host = _serverHost.text;
        [_progMeshCentralController getSocketHandler].port = _serverPort.text;
        
        if([_progMeshCentralController isServerConnected]){
            [[_progMeshCentralController getSocketHandler] disconnetToServer];
        }else{
            [[_progMeshCentralController getSocketHandler] connectToServer];
        }
    }
}
@end
