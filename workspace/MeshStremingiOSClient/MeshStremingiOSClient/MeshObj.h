//
//  MeshObj.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObj.h"

@interface MeshObj : ModelObj{
    NSString *ObjectFilePath;
    NSString *RootDirPath;
    //NSString *ObjectFileName;
}

@property (nonatomic, copy) NSString *ObjectFilePath;
@property (nonatomic, copy) NSString *RootDirPath;
@property (nonatomic, copy) NSString *ObjectFileName;

@end
