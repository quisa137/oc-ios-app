//
//  FilesViewController.h
//
//  Created by JangJaeMan on 2014. 8. 28..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilesViewCell.h"
#import "DataViewController.h"
#import "ELCImagePickerController.h"

@interface FilesViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ELCImagePickerControllerDelegate >

//UI
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) UIAlertView *alertView;

@property (nonatomic,strong)NSMutableArray *itemsOfPath;
@property (nonatomic,strong)NSMutableArray *itemsOfResult;
@property (nonatomic) NSInteger rowNo;
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) UILabel *summary;
@property (nonatomic) NSInteger dirSize;
@property (nonatomic) NSInteger fileSize;
@property (nonatomic,strong) OCFileDto *currItem;
@property (nonatomic,strong) FilesViewCell *currCell;
@property (nonatomic,strong) NSString *localFileName;
@property (nonatomic,strong) NSString *localTempFileName;
@property (nonatomic,strong) UIView *progressView;


// Local Image Path
@property (nonatomic,strong)NSString *localImagePath;

//Operations
@property(nonatomic,strong)NSOperation *uploadOperation;
@property(nonatomic,strong)NSOperation *_downloadOperation;

// Private Functions
- (void) initUI;
- (void) reloadPage;

- (void) deleteFile:(SWTableViewCell *)cell;
    
// Actions
//Upload actions
- (IBAction)showActionSheet:(id)sender;

//Close View
- (IBAction)closeView:(id)sender;

@end
