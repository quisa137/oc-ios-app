//
//  UploadsViewController.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 9. 3..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "UploadsViewController.h"
#import "UploadViewCell.h"
#import "AppDelegate.h"

@interface UploadsViewController ()

@end

@implementation UploadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTable:) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (IBAction)updateTable:(id)sender
{
    if([[AppDelegate sharedUploadData] getReloadCnt] > 0){
        [self.tableView reloadData];
        [[AppDelegate sharedUploadData] addReloadCnt:-1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0){
        // Current
        return [[AppDelegate sharedUploadData].current count];
    }else if(section == 1){
        // Failed
        return [[AppDelegate sharedUploadData].failed count];
    }else if(section == 2){
        // Uploader
        return [[AppDelegate sharedUploadData].uploader count];
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Current";
    }else if(section == 1){
        return @"Failed";
    }else if(section == 2){
        return @"Uploader";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"UploadCurrent";
        
        UploadViewCell *cell = (UploadViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell sizeToFit];
        UploadObject *t_obj =[[AppDelegate sharedUploadData].current objectAtIndex:indexPath.row];
        
        cell.image.image = [UIImage imageNamed:[[AppDelegate sharedUtilExtension] getIconName:t_obj.fileName]];
        cell.name.text = t_obj.fileName;
        cell.progress.progress = 0;
     
        [t_obj.progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:(void *)CFBridgingRetain(indexPath)];
        return cell;
    }
    if(indexPath.section == 1){
        static NSString *CellIdentifier = @"UploadUploader";
        
        UploadViewCell *cell = (UploadViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell sizeToFit];
        UploadObject *t_obj =[[AppDelegate sharedUploadData].failed objectAtIndex:indexPath.row];
        cell.image.image = [UIImage imageNamed:[[AppDelegate sharedUtilExtension] getIconName:t_obj.fileName]];
        cell.name.text = t_obj.fileName;
        cell.prop.text = t_obj.errMsg;
     
        return cell;
    }
    if(indexPath.section == 2){
        static NSString *CellIdentifier = @"UploadUploader";
        
        UploadViewCell *cell = (UploadViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell sizeToFit];
        UploadObject *t_obj =[[AppDelegate sharedUploadData].uploader objectAtIndex:indexPath.row];
        cell.image.image = [UIImage imageNamed:[[AppDelegate sharedUtilExtension] getIconName:t_obj.fileName]];
        cell.name.text = t_obj.fileName;
        cell.prop.text = [[NSString alloc] initWithFormat:@"%@, %@",[Utils timeAgoString:[t_obj.date longValue]],[Utils humanReadableSize:[t_obj.size longValue]]];
     
        return cell;
    }
 
    return nil;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        //NSString *str = (__bridge NSString *)context;
        //NSInteger section = [[str stringByDeletingLastPathComponent] integerValue];
        //NSInteger row = [[str lastPathComponent] integerValue];
        
        NSIndexPath *idxpath = (__bridge NSIndexPath *)context;
        
        //We make it on the main thread because we came from a delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            UploadViewCell *cell =  (UploadViewCell *)[self.tableView cellForRowAtIndexPath:idxpath];
            cell.progress.progress = progress.fractionCompleted;
            
            //NSLog(@"progress = %f",progress.fractionCompleted);
        });
    }
}


-(IBAction) uploadCancel:(id)sender
{
    @try {
        UIView *parentCell = ((UIButton *)sender).superview;
    
        while (![parentCell isKindOfClass:[UITableViewCell class]]) {   // iOS 7 onwards the table cell hierachy has changed.
            parentCell = parentCell.superview;
        }
        
        UIView *parentView = parentCell.superview;
        while (![parentView isKindOfClass:[UITableView class]]) {   // iOS 7 onwards the table cell hierachy has changed.
            parentView = parentView.superview;
        }
        
        UITableView *tableView = (UITableView *)parentView;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)parentCell];
        
        UploadObject *t_obj = [[AppDelegate sharedUploadData].current objectAtIndex:indexPath.row];
        [t_obj.uploadTask cancel];
        
        // Data 삭제
        [[AppDelegate sharedUploadData].current removeObjectAtIndex:indexPath.row];
        
        // Table 삭제
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
        
        NSLog(@"indexPath = %@", indexPath);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}


@end
