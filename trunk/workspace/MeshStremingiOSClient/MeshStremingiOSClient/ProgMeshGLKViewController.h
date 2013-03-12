//
//  ProgMeshGLKViewController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/14/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <GLKit/GLKit.h>



#import "ProgMeshGLManager.h"
#import "ProgMeshModel.h"
#import "Constants.h"


#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface ProgMeshGLKViewController : GLKViewController{
    ProgMeshGLManager *progMeshGLManager;
    
    ProgMeshModel *progMeshModel;
    
    enum PM_VIEW_STATUS _status;
    
}

- (void) setProgMeshGLManager : (ProgMeshGLManager *) pmglManager;

- (ProgMeshGLManager *) getProgMeshGLManager;

- (void) setProgMeshModel : (ProgMeshModel *) pmModel;

- (ProgMeshModel *) getProgMeshModel;

- (void) setScenePosition : (float *) centroidAndRadius;


@property (atomic, assign) int current_lod;
@property (atomic, assign) enum PM_VIEW_STATUS status;
@property (retain, nonatomic) IBOutlet UIProgressView *progress;
- (IBAction)decrease_screen_error:(id)sender;

@end
