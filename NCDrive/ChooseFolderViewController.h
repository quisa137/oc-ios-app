//
//  ChooseFolderViewController.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 28..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseFolderViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic,strong) NSMutableArray *itemsOfPath;
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) id parent;


// Action
-(IBAction)close:(id)sender;
-(IBAction)create:(id)sender;
-(IBAction)choose:(id)sender;

@end
