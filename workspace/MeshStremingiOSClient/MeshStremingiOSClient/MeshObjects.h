//
//  MeshObjects.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeshObj.h"
@interface MeshObjects : NSObject{
    NSMutableArray *_meshObjs;
    
}

@property (assign) NSMutableArray *MeshObjs;

- (NSInteger) size;

@end
