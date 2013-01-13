//
//  ProgMeshModelTableViewController.m
//  MeshStremingiOSClient
//
//  Created by Xu Haiyang on 11/15/12.
//  Copyright (c) 2012 Xu Haiyang. All rights reserved.
//

#import "ProgMeshModelTableViewController.h"
#import "ProgMeshModel.h"
#import "AppDelegate.h"
#import "MeshObj.h"
#import "VolumeObj.h"
#import "MeshObjects.h"
#import "VolumeObjects.h"
#import "ModelDetailViewController.h"
#import "ModelObj.h"
#import <UIKit/UIColor.h>

@interface ProgMeshModelTableViewController (){
    
}

@end

@implementation ProgMeshModelTableViewController

@synthesize meshList = _meshList, volumeList = _volumeList, selectedProgMeshModel = _selectedProgMesh, lastIndexPath, models = _models, meshes = _meshes, volumes = _volumes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Models", @"Models");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(_meshes == nil || _volumes == nil){
        return 0;
    }
    
    if(section == 0){
        return _meshes.count;
    }
    else if(section == 1){
        return _volumes.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([indexPath compare:self.lastIndexPath] == NSOrderedSame)
    {
        [cell setSelected:YES];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [cell setHighlighted:YES];
        [cell setSelected:YES];
        
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    
    
    if(indexPath.section == 0 && _meshes != nil){
        //mesh
        MeshObj *mobj = [_meshes objectAtIndex:indexPath.row];
        
        NSString *name = mobj.ObjectFileName;
        cell.textLabel.text = name;
        
    } else if(indexPath.section == 1 && _volumes != nil){
        //volume
        
        VolumeObj *vobj = [_volumes objectAtIndex:indexPath.row];
        
        NSString *name = vobj.ObjectFileName;
        cell.textLabel.text = name;
    }
    
    
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Mesh";
    else
        return @"Volume";
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *MyIdentifier = @"MyIdentifier";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
	}
    
    ModelObj *model;
    switch (indexPath.section) {
        case 0:
            model = [_meshes objectAtIndex:indexPath.row];
            break;
            
        case 1:
            model = [_volumes objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    
    self.lastIndexPath = indexPath;
    
    [tableView reloadData];
    
    [[ProgMeshCentralController sharedInstance] didSelectModelToLoad:model];
}

- (void) resetTable
{
    [_meshes release];
    _meshes = nil;
    
    [_volumes release];
    _volumes = nil;
    
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Button number : %d", indexPath.row );
    
    ModelObj *model;
    switch (indexPath.section) {
        case 0:
            model = [_meshes objectAtIndex:indexPath.row];
            break;
            
        case 1:
            model = [_volumes objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    
    ModelDetailViewController *modelDetailViewController = [[ModelDetailViewController alloc] initWithNibName:@"ModelDetailViewController" bundle:[NSBundle mainBundle]];
    
    modelDetailViewController.aModel = model;
    
    [self.navigationController pushViewController:modelDetailViewController animated:YES];
    [modelDetailViewController release];
    modelDetailViewController = nil;
}



@end
