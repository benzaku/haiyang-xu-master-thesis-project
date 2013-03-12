//
//  ModelDetailViewController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/4/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelObj.h"

@interface ModelDetailViewController : UITableViewController{
    ModelObj * _aModel;
}


@property (assign) ModelObj *aModel;
@end
