//
//  ProgMeshModelTableViewController.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProgMeshModelArray.h"

#import "ProgMeshModel.h"

@interface ProgMeshModelTableViewController : UITableViewController{
    ProgMeshModelArray *_meshList;
    ProgMeshModelArray *_volumeList;
    
    NSIndexPath *lastIndexPath;
    
    ProgMeshModel *_selectedProgMeshModel;
}


@property (nonatomic, strong) ProgMeshModel *selectedProgMeshModel;
@property (retain, nonatomic) ProgMeshModelArray *meshList;
@property (retain, nonatomic) ProgMeshModelArray *volumeList;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;




@end
