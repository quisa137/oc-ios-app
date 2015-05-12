//
//  ChooseFolderViewController.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 28..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "ChooseFolderViewController.h"
#import "FilesViewController.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCFileDto.h"
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCCommunication.h"
#import "ChooseFolderCell.h"

@interface ChooseFolderViewController ()

@end

@implementation ChooseFolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if(self.path == nil){
        self.path = PathPrefix;
    }
    
    [self showFolder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark owncloud action
- (void) showFolder {
    
    NSString *t_path = [Utils getHomeURLwithPath:self.path];
    NSLog(@"t_Path: %@", t_path);
    
    t_path = [t_path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *hud = nil;
	hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDAnimationFade;
	hud.labelText = @"Loading";
    
    [[AppDelegate sharedOCCommunication] readFolder:t_path onCommunication:[AppDelegate sharedOCCommunication] successRequest:^(NSHTTPURLResponse *response, NSArray *items, NSString *redirected) {
        
        //Success
		[hud hide:YES];
        
        NSLog(@"succes");
        for (OCFileDto *itemDto in items) {
            //Check parser
            NSLog(@"Item file name: %@", itemDto.fileName);
            NSLog(@"Item file path: %@", itemDto.filePath);
        }
        
        NSMutableArray *t_array = [[NSMutableArray alloc] init];
        
        // Add Directories
        for(OCFileDto *itemDto in items){
            if(![itemDto isDirectory]){
                continue;
            }
            if(itemDto.fileName == nil){
                continue;
            }
            [t_array addObject:itemDto];
        }
        
        self.itemsOfPath = [NSMutableArray arrayWithArray:t_array];
        [self.tableView reloadData];

    } failureRequest:^(NSHTTPURLResponse *response, NSError *error) {
        //Request failure
		[hud hide:YES];
		[Utils showAlert:@"Loading" withMsg:[error localizedDescription]];
    }];
}


# pragma mark UITableViewDelegate

// Asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Returns the table view managed by the controller object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCFileDto *itemDto = [self.itemsOfPath objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"folderCell";
    
    ChooseFolderCell *cell = (ChooseFolderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ChooseFolderCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell sizeToFit];
    }
    
    cell._myTextLabel.text = [itemDto.fileName stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];
    cell._myImageView.image = [UIImage imageNamed:@"folder.png"];
    return cell;
}

-(void) tableView:(UITableView *) tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCFileDto *itemDto = [self.itemsOfPath objectAtIndex:indexPath.row];
    
    if(itemDto.isDirectory){
        NSLog(@"Selected Row is = %d",indexPath.row);
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ChooseFolderViewController *fvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChooseFolderViewController"];
        
		fvc.path = [[NSString alloc] initWithFormat:@"%@/%@",self.path, itemDto.fileName];
        fvc.parent = self.parent;
        [[self navigationController] pushViewController:fvc animated:YES];
        return;
    }
}

// Returns the table view managed by the controller object.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.itemsOfPath) {
        return 0;
    } else {
        return [self.itemsOfPath count];
    }
}


# pragma mark IBACtion
-(IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)create:(id)sender {
    // Input new Folder Name
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"디렉터리 이름 입력"
                                              message:nil
                                             delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"OK", nil];

    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message show];
}

-(IBAction)choose:(id)sender {
    OCFileDto *fileDto = nil;
    FilesViewCell *fileCell = nil;
    FilesViewController *fvc = nil;
    
    if ([self.parent class] == [FilesViewController class]) {
        fvc = (FilesViewController *)self.parent;
        fileDto = fvc.currItem;
        fileCell = fvc.currCell;
    }
    
    NSString *fromPath = [Utils getHomeURLwithPath:[fileDto.filePath stringByAppendingString:fileDto.fileName]];
    NSArray *toPaths = [[NSArray alloc] initWithObjects:self.path,fileDto.fileName,nil];
    
    NSString *toPath = [Utils getHomeURLwithPath:[toPaths componentsJoinedByString:@"/"]];
    
    if(fileDto.isDirectory){
        // Add slash at the end of text
        [fromPath stringByAppendingString:@"/"];
        [toPath stringByAppendingString:@"/"];
    }
    
    NSLog(@"fromPath=%@",fromPath);
    NSLog(@"toPath=%@",toPath);
    
    MBProgressHUD *hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Moving....";
    
    
    [[AppDelegate sharedOCCommunication] moveFileOrFolder:fromPath toDestiny:toPath onCommunication:[AppDelegate sharedOCCommunication]
                                           successRequest:^(NSHTTPURLResponse *response, NSString *redirectServer){
                                               [hud hide:YES];
                                               NSIndexPath *cellIndexPath = [fvc.tableView indexPathForCell:fileCell];
                                               
                                               // Delete Cell
                                               [fvc.itemsOfPath removeObjectAtIndex:cellIndexPath.row];
                                               NSArray *deleteIndexPaths = [NSArray arrayWithObjects:cellIndexPath,nil];
                                               [fvc.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
                                               
                                               [fvc dismissViewControllerAnimated:YES completion:nil];
                                           }
                                           failureRequest:^(NSHTTPURLResponse *response, NSError *error){
                                               if (response.statusCode == 401){
                                                   //[parent redirectloginView];
                                               } else {
                                                   [hud hide:YES];
                                                   [Utils showAlert:@"Move Error" withMsg:[error localizedDescription]];
                                               }
                                           }
                                       errorBeforeRequest:^(NSError *error){
                                           [hud hide:YES];
                                           [Utils showAlert:@"Move Error" withMsg:[error localizedDescription]];
                                       }];
}


#pragma mark - AlertView Delegate
// ------------------------------------------------------------------------------------------
- (void) createFolder:(NSString *)folderName {
    // Make Folder Path
    NSString *t_path = [Utils getFileURLwithPath:self.path withFileName:folderName];
    
    // Create Folder;
    NSLog(@"path info = %@",t_path);
    
    MBProgressHUD *hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Loading";

    [[AppDelegate sharedOCCommunication] createFolder:t_path onCommunication:[AppDelegate sharedOCCommunication]
           successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer){
               [hud hide:YES];
              // Success , Reload Data
               [self showFolder];
           }
           failureRequest:^(NSHTTPURLResponse *response, NSError *error){
               [hud hide:YES];
           }
           errorBeforeRequest:^(NSError *error){
               [hud hide:YES];
               [Utils showAlert:@"Create Fail" withMsg:[error localizedDescription]];
           }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView title];
    NSString *bt_title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"디렉터리 이름 입력"])
    {
        if([bt_title isEqualToString:@"OK"])
        {
            UITextField *folderName = [alertView textFieldAtIndex:0];
            [self createFolder:[folderName text]];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
