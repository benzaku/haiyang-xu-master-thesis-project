//
//  GLRenderViewController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/22/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

#import "ProgMeshGLManager.h"
#import "ProgMeshModel.h"
#import "Constants.h"

@interface GLRenderViewController : UIViewController{
    ProgMeshGLManager *progMeshGLManager;
    
    ProgMeshModel *progMeshModel;
    
    enum PM_VIEW_STATUS _status;
}

- (void) startAnimation;
- (void) stopAnimation;

- (ProgMeshModel *) getProgMeshModel;

- (void) setProgMeshModel : (ProgMeshModel *) pmModel;

@property (retain, nonatomic) IBOutlet EAGLView *glView;

@property (atomic, assign) enum PM_VIEW_STATUS status;

@end
