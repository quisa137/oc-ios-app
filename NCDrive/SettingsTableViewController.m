//
//  SettingsTableViewController.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 26..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "SettingsTableViewController.h"
#import "Utils.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.hidden = NO;

    if ([indexPath row]==2){
        if ([Utils versionCompare]>=0) {
            cell.hidden = YES;
        }
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNo = indexPath.row;
    NSInteger secNo = indexPath.section;
    
    if(secNo == 0 && rowNo == 1){
        if (IS_IPAD && IS_OS_8_OR_LATER) {
            NSString* mailto = [NSString stringWithFormat:@"mailto://%@",[Utils getPlistConfigForKey:@"adminMail"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailto]];
        }else{
            // Send Mail FeedBack
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            if ([MFMailComposeViewController canSendMail]) {
                [picker setSubject:@"NCDrive Feedback"];
                [picker setToRecipients:@[[Utils getPlistConfigForKey:@"adminMail"]]];
                //[picker setCcRecipients:@[@""]];
                [picker setMessageBody:nil isHTML:NO];
                
                picker.navigationBar.barStyle = UIBarStyleDefault;
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }else if(secNo == 0 && rowNo == 2){
        NSURL* url = [[NSURL alloc] initWithString:@"https://appcenter.ncsoft.com"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

# pragma mark MailComposeDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
        {
            [Utils showAlert:@"Email" withMsg:@"Sending Failed - Unknown Error :-("];
        }
        break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    
    switch (section){
        case 0:
            sectionName = [NSString stringWithFormat:@"v%@",[Utils currentVersion]];
            break;
        default:
            sectionName = @"NCDrive 2014";
            break;
    }
    return sectionName;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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

@end
