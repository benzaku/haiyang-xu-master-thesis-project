//
//  VolumeObj.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/3/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "VolumeObj.h"

@implementation VolumeObj

@synthesize ObjectFilePath;
@synthesize RootDirPath;
@synthesize Format;
@synthesize GridType;
@synthesize NbrTags;
@synthesize ObjectFileName;
@synthesize ObjectModel;
@synthesize ObjectType;
@synthesize Resolution;
@synthesize SliceThickness;
@synthesize TaggedFileName;


- (void)dealloc
{
    [ObjectFilePath release];
    ObjectFilePath = nil;
    [RootDirPath release];
    RootDirPath = nil;
    [Format release];
    Format = nil;
    [GridType release];
    GridType = nil;
    [NbrTags release];
    NbrTags = nil;
    [ObjectFileName release];
    ObjectFileName = nil;
    [ObjectModel release];
    ObjectModel = nil;
    [ObjectType release];
    ObjectType = nil;
    [Resolution release];
    Resolution = nil;
    [SliceThickness release];
    SliceThickness = nil;
    [TaggedFileName release];
    TaggedFileName = nil;
    
    [super dealloc];
}
@end
