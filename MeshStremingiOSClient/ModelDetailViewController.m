//
//  ModelDetailViewController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 12/4/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ModelDetailViewController.h"

#import "MeshObj.h"
#import "VolumeObj.h"

@interface ModelDetailViewController (){
    //NSInteger _numberOfRows;
    NSMutableDictionary *_attrMap;
}

@end

@implementation ModelDetailViewController

@synthesize aModel = _aModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Model Detail";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _aModel.ObjectFileName;
    
    
    
    if (_aModel != nil) {
        
        _attrMap = [_aModel getModelAttributesMap];
        
        NSLog(@"_attrMap : \n %@", _attrMap);
        if([_aModel isMemberOfClass: [MeshObj class]]){
            NSLog(@"it's a mesh!");
            
            
        } else if ([_aModel isMemberOfClass:[VolumeObj class]]){
            NSLog(@"it's a volume!");
        }
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //there is only one section
    return [_attrMap count];
    //return 0;
    
}








- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSMutableString *rtn = [[NSMutableString alloc] initWithString:@"Attributes of Model "];
    
    [rtn appendString:_aModel.ObjectFileName];
    
    return  rtn;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    
    
    NSString * key = [[_attrMap allKeys] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = key;
    
    cell.detailTextLabel.text = [_attrMap objectForKey:key];
    
    // Configure the cell...
    
    return cell;
}

- (void) dealloc
{
    
    //[_aModel release];
    //_aModel = nil;
    [_attrMap release];
    _attrMap = nil;
    
    [super dealloc];
}

@end
