//
//  AccountManagerController.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 26..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "AccountManagerController.h"
#import "FilesViewController.h"
#import "Utils.h"
#import "AppDelegate.h"

@interface AccountManagerController ()

@end

@implementation AccountManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *hostUrl = [Utils getConfigForKey:@"host"];
    if (hostUrl.length <= 0) {
        hostUrl = [Utils getPlistConfigForKey:@"host"];
    }
    // SetUP Fields
    self._hostText.text = hostUrl;
    self._hostText.enabled = YES;
    self.isLogined = ([Utils getConfigForKey:@"userid"]!=nil && [Utils getConfigForKey:@"passwd"]!=nil);
    if (self.isLogined) {
        self._userIdText.text = [Utils getConfigForKey:@"userid"];
        self._passwdText.text = [Utils getConfigForKey:@"passwd"];
        [self._doButton setTitle:@"Logout" forState:UIControlStateNormal];
    }else{
        [self._doButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isLogined = ([Utils getConfigForKey:@"userid"]!=nil && [Utils getConfigForKey:@"passwd"]!=nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginoutToggle:(id)sender {
    if(self.isLogined) {
        [self logoutAction:sender];
    } else {
        [self loginAction:sender];
    }
}

- (void)loginAction:(id)sender {
    // check Parameter
    if(self._userIdText == nil || self._userIdText.text.length < 1){
        [Utils showAlert:@"Error" withMsg:@"Invalid User ID"];
        return;
    }
    if(self._passwdText == nil || self._passwdText.text.length < 1){
        [Utils showAlert:@"Error" withMsg:@"Invalid Password"];
        return;
    }
    
    // Save Data
    [Utils setConfigForKey:@"host" withValue:self._hostText.text withSync:NO];
    [Utils setConfigForKey:@"userid" withValue:self._userIdText.text withSync:NO];
    [Utils setConfigForKey:@"passwd" withValue:self._passwdText.text withSync:YES];
    
    // Save Dirty
    [[AppDelegate sharedState] setDirtyWithType:kDTUser];
    
    // Go To Prev Page
    if([self navigationController] != nil){
        [[self navigationController] popViewControllerAnimated:YES];
    }else{
        [(FilesViewController *)self._pv reloadPage];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)logoutAction:(id)sender {
    //로그인 세션 삭제
    [Utils setConfigForKey:@"userid" withValue:nil withSync:YES];
    [Utils setConfigForKey:@"passwd" withValue:nil withSync:YES];
    [[AppDelegate sharedState] clearDirty];
    [[AppDelegate sharedState] clearDirtyWithType:kDTUnknown];
    
    [[AppDelegate sharedOCCommunication] setCredentialsWithUser:nil andPassword:nil];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate resetViews];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self._passwdText isFirstResponder] && [touch view] != self._passwdText) {
        [self._passwdText resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=44.0;
    if(indexPath.section == 0){
        height = 80.0;
    }else if(indexPath.section == 1){
    }else if(indexPath.section == 2){
    }
    return height;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 0){
        [self loginoutToggle:nil];
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
