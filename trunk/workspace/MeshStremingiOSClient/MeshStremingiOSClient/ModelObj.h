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
    NSString *Id;
}

@property (nonatomic, copy) NSString *ObjectFileName;
@property (nonatomic, copy) NSString *Id;

- (NSMutableDictionary *) getModelAttributesMap;
@end
