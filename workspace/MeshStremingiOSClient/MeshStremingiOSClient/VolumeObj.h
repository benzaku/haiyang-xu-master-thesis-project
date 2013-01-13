//
//  VolumeObj.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObj.h"

@interface VolumeObj : ModelObj{
    NSString *ObjectFilePath;
    NSString *RootDirPath;
    NSString *Format;
    NSString *GridType;
    NSString *NbrTags;
    
    //NSString *ObjectFileName;
    
    NSString *ObjectModel;
    NSString *ObjectType;
    NSString *Resolution;
    NSString *SliceThickness;
    NSString *TaggedFileName;
}

@property (nonatomic, copy) NSString *ObjectFilePath;
@property (nonatomic, copy) NSString *RootDirPath;
@property (nonatomic, copy) NSString *Format;
@property (nonatomic, copy) NSString *GridType;
@property (nonatomic, copy) NSString *NbrTags;


@property (nonatomic, copy) NSString *ObjectFileName;
@property (nonatomic, copy) NSString *Id;

@property (nonatomic, copy) NSString *ObjectModel;
@property (nonatomic, copy) NSString *ObjectType;
@property (nonatomic, copy) NSString *Resolution;
@property (nonatomic, copy) NSString *SliceThickness;
@property (nonatomic, copy) NSString *TaggedFileName;
@end
