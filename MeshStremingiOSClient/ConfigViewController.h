//
//  ConfigViewController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/27/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigViewController : UIViewController{
    //ProgMeshCentralController * _progMeshCentralController;
}

@property (retain, nonatomic) IBOutlet UITextField *serverHost;
@property (retain, nonatomic) IBOutlet UITextField *serverPort;
//@property (strong, atomic) ProgMeshCentralController * progMeshCentralController;
@property (retain, nonatomic) IBOutlet UILabel *statusBar;

@property (retain, nonatomic) IBOutlet UIButton *connectButton;


- (IBAction)serverConnect:(UIButton *)sender;
@end
