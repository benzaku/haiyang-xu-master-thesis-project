//
//  ModelObj.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/4/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelObj : NSObject{
    NSString *ObjectFileName;
}

@property (nonatomic, copy) NSString *ObjectFileName;

- (NSMutableDictionary *) getModelAttributesMap;
@end
