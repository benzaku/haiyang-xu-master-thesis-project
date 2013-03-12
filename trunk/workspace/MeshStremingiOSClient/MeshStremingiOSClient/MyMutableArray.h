//
//  MyMutableArray.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 3/9/13.
//  Copyright (c) 2013 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyMutableArray : NSMutableArray

@property (atomic, assign) NSInteger headPointer;
@end
