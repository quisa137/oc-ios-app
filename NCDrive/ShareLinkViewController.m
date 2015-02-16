//
//  ShareLinkViewController.m
// 
//  @author jacojang <jacojang@jacojang.com>
//

#import "ShareLinkViewController.h"
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCCommunication.h"
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCSharedDto.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "MBProgressHUD.h"


//For the example works you must be enter your server data

//Your entire server url. ex:https://example.owncloud.com/owncloud/remote.php/webdav/
static NSString *pathPrefix = @"/remote.php/webdav";


@interface ShareLinkViewController ()

@property (nonatomic) BOOL usedSessions;

@end

@implementation ShareLinkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//Properties
    _usedSessions = NO;
    
    // Init UI
    [self initUI];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(deviceOrientationDidChange:)
                                                   name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)reloadPage
{
    //Set credentials once
    [self setCredencialsInOCCommunication];
    
    // Show Data !!
    [self showShareLinkList:nil]; 
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if([[AppDelegate sharedState] isDirty]){
        [self reloadPage];
//        [[AppDelegate sharedState] clearDirty];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initUI
{
    self.tableView.rowHeight = 50;
    
    // Set Title
    
    // Setup refresh control for example app
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
}

#pragma mark - Actions

#pragma mark - OCComunication Methods

///-----------------------------------
/// @name Set Credentials in OCCommunication
///-----------------------------------

/**
 * Set username and password in the OCComunicacion
 */
- (BOOL) setCredencialsInOCCommunication {
    
    NSString *userid = [Utils getConfigForKey:@"userid"];
    NSString *passwd = [Utils getConfigForKey:@"passwd"];
    
    //Sett credencials
    [[AppDelegate sharedOCCommunication] setCredentialsWithUser:userid andPassword:passwd];
    
    return YES;
}

- (void) unSharedLink:(SWTableViewCell *)cell{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    OCSharedDto *itemDto = [[self itemsOfPath] objectAtIndex:cellIndexPath.row];
    
    NSString *t_path = [Utils getConfigForKey:@"host"];
    t_path = [t_path stringByAppendingString:@"/"];
    NSLog(@"t_Path: %@", t_path);

    t_path = [t_path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"path=%@",t_path);
    
    MBProgressHUD *hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = @"Unshare....";

    //Delete Block
    
    [[AppDelegate sharedOCCommunication] unShareFileOrFolderByServer:t_path andIdRemoteShared:itemDto.idRemoteShared
                                         onCommunication:[AppDelegate sharedOCCommunication]
    successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer){
        //Success
        [hud hide:YES];

        // Delete Cell
        [self.itemsOfPath removeObjectAtIndex:cellIndexPath.row];
        NSArray *deleteIndexPaths = [NSArray arrayWithObjects:cellIndexPath,nil];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
    failureRequest:^(NSHTTPURLResponse *response, NSError *error){
        //Failure
        [hud hide:YES];

        if(self.alertView != nil){ self.alertView = nil; }
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Unshare Fail" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
        [self.alertView show];
    }];
}

- (void) showShareLinkList:(UIRefreshControl *)refreshctrl {
    
    NSString *t_path = [Utils getConfigForKey:@"host"];
    t_path = [t_path stringByAppendingString:@"/"];
    NSLog(@"t_Path: %@", t_path);
    
    t_path = [t_path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *hud = nil;
    if(refreshctrl == nil){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        hud.labelText = @"Loading";
    }
 
    [[AppDelegate sharedOCCommunication] readSharedByServer:t_path onCommunication:[AppDelegate sharedOCCommunication]
     successRequest: ^(NSHTTPURLResponse *response, NSArray *listOfShared, NSString *redirectedServer){
        //Success
        if(hud == nil){
            [refreshctrl endRefreshing];
        }else{
            [hud hide:YES];
        }
        
        NSMutableArray *t_array = [[NSMutableArray alloc] init];
        
        // Add Directories
        for(OCSharedDto *itemDto in listOfShared){
            if(![itemDto isDirectory]){
                continue;
            }
            if([itemDto shareType] != shareTypeLink){ continue ; }
            [t_array addObject:itemDto];
        }
        
        // Add Files
        for(OCSharedDto *itemDto in listOfShared){
            if([itemDto isDirectory]){
                continue;
            }
            if([itemDto shareType] != shareTypeLink){ continue ; }
            [t_array addObject:itemDto];
        }
        
        self.itemsOfPath = nil;
        self.itemsOfPath = [NSMutableArray arrayWithArray:t_array];
        
        [self.tableView reloadData];    
     }
     failureRequest:^(NSHTTPURLResponse *response, NSError *error){
        //Request failure
        if(hud == nil){
            [refreshctrl endRefreshing];
        }else{
            [hud hide:YES];
        }

        if(self.alertView != nil){ self.alertView = nil; }
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Loading Fail" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
        [self.alertView show];   
     }];
}

#pragma mark - UITableView DataSource
- (void)toggleCells:(UIRefreshControl*)refreshControl
{
    [refreshControl beginRefreshing];
    [self showShareLinkList:refreshControl];
}


// Asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Returns the table view managed by the controller object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCSharedDto *itemDto = [self.itemsOfPath objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"DefaultCell2";
    
    FilesViewCell *cell = (FilesViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    [cell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:120];
    [cell sizeToFit];
    
    NSString *filename = [itemDto.path lastPathComponent];
    NSString *pathname = [itemDto.path stringByDeletingLastPathComponent];
    
    cell.name.text = [filename stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];
    
    if(itemDto.isDirectory){
        cell.image.image = [UIImage imageNamed:@"folder.png"];
        cell.cacheImage.image = nil;
        // Prop Print
        cell.prop.text = [[NSString alloc] initWithFormat:@"%@", pathname];
    }else{
        cell.image.image = [UIImage imageNamed:[[AppDelegate sharedUtilExtension] getIconName:filename]];
        
        // Prop Print
        cell.prop.text = [[NSString alloc] initWithFormat:@"%@",pathname];
    }
    return cell;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:0.88f green:0.88f blue:0.9f alpha:1.0] title:@"Share Link"];
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@"Unshare Link"];
    
    return leftUtilityButtons;
}

// --------------------------------------------------------------------------
// UITableView Delegate
// --------------------------------------------------------------------------
-(void) tableView:(UITableView *) tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 선택시 아무 Action도 없다.
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


// Set row height on an individual basis

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [self rowHeightForIndexPath:indexPath];
//}
//
//- (CGFloat)rowHeightForIndexPath:(NSIndexPath *)indexPath {
//    return ([indexPath row] * 10) + 60;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    
    switch (index) {
        case 0:
        {
            // Share Link
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            OCSharedDto *itemDto = [[self itemsOfPath] objectAtIndex:cellIndexPath.row];
 
            NSLog(@"itemDto1=%ld", (long)itemDto.idRemoteShared);
            NSLog(@"itemDto1=%hhd", itemDto.isDirectory);
            NSLog(@"itemDto1=%ld", (long)itemDto.itemSource);
            NSLog(@"itemDto1=%ld", (long)itemDto.parent);
            NSLog(@"itemDto1=%ld", (long)itemDto.shareType);
            NSLog(@"itemDto1=%@", itemDto.shareWith);
            NSLog(@"itemDto1=%ld", (long)itemDto.fileSource);
            NSLog(@"itemDto1=%@", itemDto.path);
            NSLog(@"itemDto1=%ld", (long)itemDto.permissions);
            NSLog(@"itemDto1=%ld", itemDto.sharedDate);
            NSLog(@"itemDto1=%ld", itemDto.expirationDate);
            NSLog(@"itemDto1=%@", itemDto.token);
            NSLog(@"itemDto1=%ld", (long)itemDto.storage);
            NSLog(@"itemDto1=%ld", (long)itemDto.mailSend);
            NSLog(@"itemDto1=%@", itemDto.uidOwner);
            NSLog(@"itemDto1=%@", itemDto.shareWithDisplayName);
            NSLog(@"itemDto1=%@", itemDto.displayNameOwner);

            
            NSString *t_path = [[NSString alloc] initWithFormat:@"%@/public.php?service=files&t=%@",[Utils getConfigForKey:@"host"],itemDto.token];
            
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[t_path] applicationActivities:nil];
            if(IS_IPAD && IS_OS_8_OR_LATER){
                activityView.popoverPresentationController.sourceView = [self view];
            }
            [self presentViewController:activityView animated:YES completion:^{
                [cell hideUtilityButtonsAnimated:YES];
            }];
            break;
        }
        case 1:
        {
            // Unshare Link
            [self unSharedLink:cell];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}


@end
