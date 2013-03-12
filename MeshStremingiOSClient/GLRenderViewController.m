//
//  GLRenderViewController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 1/22/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import "GLRenderViewController.h"

@interface GLRenderViewController (){
    //Quaternion things
    GLKMatrix4 _rotMatrix;
    GLKVector3 _anchor_position;
    GLKVector3 _current_position;
    GLKQuaternion _quatStart;
    GLKQuaternion _quat;
    
    BOOL _slerping;
    float _slerpCur;
    float _slerpMax;
    GLKQuaternion _slerpStart;
    GLKQuaternion _slerpEnd;
    
    float _curRed;
    BOOL _increasing;
    
    float zoomDistance;
}

@end


@implementation GLRenderViewController

@synthesize status = _status;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"GLRenderer", @"GLRenderer");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    
    progMeshModel = nil;
    
    _status = PM_VIEW_STATUS_NONE;
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_glView startAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startAnimation{
    [_glView startAnimation];
}
- (void) stopAnimation{
    [_glView stopAnimation];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_glView stopAnimation];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_glView stopAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_glView startAnimation];
}

- (ProgMeshModel *) getProgMeshModel
{
    return progMeshModel;
}

- (void) setProgMeshModel : (ProgMeshModel *) pmModel
{
    progMeshModel = pmModel;
}


- (void)dealloc {
    [_glView release];
    [super dealloc];
}
@end
