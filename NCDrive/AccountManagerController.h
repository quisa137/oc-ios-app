//
//  AccountManagerController.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 26..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountManagerController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *_hostText;
@property (weak, nonatomic) IBOutlet UITextField *_userIdText;
@property (weak, nonatomic) IBOutlet UITextField *_passwdText;
@property (weak, nonatomic) IBOutlet UIButton *_doButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *_logoutTableCell;
@property (weak, nonatomic) id _pv;
@property (nonatomic) BOOL isLogined;

@end
