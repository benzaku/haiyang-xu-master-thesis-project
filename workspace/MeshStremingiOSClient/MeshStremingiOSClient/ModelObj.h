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
    NSString *ModelType;
}

@property (nonatomic, copy) NSString *ObjectFileName;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *ModelType;

- (NSMutableDictionary *) getModelAttributesMap;
@end
