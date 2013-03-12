//
//  AppDelegate.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/14/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProgMeshCentralController.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>{
    ProgMeshCentralController *_progMeshCentralController;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, atomic) ProgMeshCentralController *progMeshCentralController;

@end
