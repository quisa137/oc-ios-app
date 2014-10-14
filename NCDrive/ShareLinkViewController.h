//
//  ShareLinkViewController.h
//
// @author jacojang <jacojang@jacojang.com>
//

#import <UIKit/UIKit.h>
#import "FilesViewCell.h"

@interface ShareLinkViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UINavigationControllerDelegate>

//UI
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) UIAlertView *alertView;

@property (nonatomic,strong)NSMutableArray *itemsOfPath;
@property (nonatomic) NSInteger rowNo;

// Local Image Path
@property (nonatomic,strong)NSString *localImagePath;

//Operations
@property(nonatomic,strong)NSOperation *uploadOperation;

// Private Functions
- (void) initUI;

@end
