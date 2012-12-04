//
//  VolumeObjects.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VolumeObjects : NSObject{
    NSMutableArray *VolumeObjs;
}

@property (assign) NSMutableArray * VolumeObjs;

- (NSInteger) size;

@end
