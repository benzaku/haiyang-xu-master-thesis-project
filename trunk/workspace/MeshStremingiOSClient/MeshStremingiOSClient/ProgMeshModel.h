//
//  ProgMeshModel.h
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgMeshModel : NSObject{
    NSString * _type;
    NSString * _name;
}

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;

@end
