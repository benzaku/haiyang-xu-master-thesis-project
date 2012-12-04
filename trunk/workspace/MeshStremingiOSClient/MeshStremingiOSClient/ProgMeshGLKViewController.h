//
//  ProgMeshGLKViewController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/14/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ProgMeshCentralController.h"

@interface ProgMeshGLKViewController : GLKViewController{
    ProgMeshCentralController * _progMeshCentralController;

}

@property (strong, nonatomic) ProgMeshCentralController * progMeshCentralController;


@end
