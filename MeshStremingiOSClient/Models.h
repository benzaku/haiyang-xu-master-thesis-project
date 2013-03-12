//
//  Models.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VolumeObjects.h"
#import "MeshObjects.h"

@interface Models : NSObject{
    VolumeObjects *VolumeObjects;
    MeshObjects *MeshObjects;
}

@property (assign) VolumeObjects *VolumeObjects;
@property (assign) MeshObjects *MeshObjects;

- (NSInteger) volumeCount;

- (NSInteger) meshCount;

@end
