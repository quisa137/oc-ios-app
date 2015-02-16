//
//  FilesViewController.m
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FilesViewController.h"
#import "AccountManagerController.h"
#import "OCCommunication.h"
#import "OCSharedDto.h"
#import "OCFileDto.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "ChooseFolderViewController.h"


//For the example works you must be enter your server data

//Your entire server url. ex:https://example.owncloud.com/owncloud/remote.php/webdav/
static NSString *pathPrefix = @"/remote.php/webdav";
bool dissmissAppupdate = false;


@interface FilesViewController ()

@property (nonatomic) BOOL usedSessions;

@end

@implementation FilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//Properties
    _usedSessions = NO;

    
    // Initail Variable
    self.currItem = nil;
    if(self.path == nil){
        self.path = PathPrefix;
    }
    
    // Init UI
    [self initUI];
    
    // Show
    [self reloadPage];
    
    // Get App upate info
    if (!dissmissAppupdate) {
        NSString *path = [[Utils getPlistConfigForKey:@"appUpdateInfoUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        FilesViewController *caller = self;
        [[AppDelegate sharedOCCommunication] readAppUpdateInfo:path onCmmunication:[AppDelegate sharedOCCommunication]
                                                successRequest:^(NSHTTPURLResponse *response, NSString *versionString){
                                                    if ([Utils versionCompare:versionString] < 0) {
                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NCDrive Updated" message:@"New version available. Are you go to App Center?" delegate:caller cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                                                        [alert show];
                                                    }
                                                }
                                                failureRequest:^(NSHTTPURLResponse *response, NSError *error){
                                                    [Utils showAlert:@"Unable Get App Update Version" withMsg:[error localizedDescription]];
                                                }
         ];
    }


    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                             name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([Utils getConfigForKey:@"userid"]==nil || [Utils getConfigForKey:@"passwd"]==nil) {
        [self reloadPage];
    }
    [self.tableView reloadData];
    [self initUI];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self.tableView reloadData];
    [self initUI];
}


- (void)viewDidAppear:(BOOL)animated
{
    if([[AppDelegate sharedState] isDirty]){
        [self reloadPage];
        [[AppDelegate sharedState] clearDirty];
    }
    
    NSString *t_server_path = [Utils getHomeURLwithPath:@""];
    NSString *t_file_path = [self.path stringByReplacingOccurrencesOfString:PathPrefix withString:@"/"];
    
    t_file_path = [t_file_path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(![t_server_path isEqualToString:@"(null)/"]) {
        [[AppDelegate sharedOCCommunication] readSharedByServer:t_server_path andPath:t_file_path onCommunication:[AppDelegate sharedOCCommunication]
                                                 successRequest:^(NSHTTPURLResponse *response, NSArray *listOfShared, NSString *redirectedServer) {
                                                     self.sharedCurPath = listOfShared;
                                                 } failureRequest:^(NSHTTPURLResponse *response, NSError *error) {
                                                     if (response.statusCode == 401){
                                                         [self redirectloginView];
                                                     }else{
                                                         [Utils showAlert:@"File View Error" withMsg:[error localizedDescription]];
                                                     }
                                                 }
         ];
    }
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
    if(self.path != nil && self.path != PathPrefix) {
        self.title = [[self.path lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        UIImageView *tview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_32pt.png"]];
        self.navigationItem.titleView = tview;
    }
        
    // Setup refresh control for example app
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    
    //Cell들의 재정렬 이슈 해결
    for(FilesViewCell *cell in [self.tableView visibleCells]){
        [cell hideUtilityButtonsAnimated:NO];
    }
}

#pragma mark - Actions
- (IBAction) showActionSheet:(id)sender
{
    if (IS_OS_8_OR_LATER) {
        UIAlertController* alertController = nil;
        alertController = [UIAlertController alertControllerWithTitle:@"Upload" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        id actionHandler = ^(UIAlertAction *action){
            [self executeCommand:[action title]];
        };
        UIAlertAction* uploadPhotoVideoAction = [UIAlertAction actionWithTitle:@"Upload Photo/Video" style:UIAlertActionStyleDefault handler:actionHandler];
        UIAlertAction* newfolderAction = [UIAlertAction actionWithTitle:@"New folder" style:UIAlertActionStyleDefault handler:actionHandler];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:actionHandler];
        [alertController addAction:uploadPhotoVideoAction];
        [alertController addAction:newfolderAction];
        [alertController addAction:cancelAction];
        
        if(IS_IPAD && IS_OS_8_OR_LATER){
            [alertController popoverPresentationController].sourceView = [sender view];
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        UIActionSheet *actionSheet = nil;
        
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:@"Upload"
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                       otherButtonTitles:@"Upload Photo/Video",@"New folder",nil];
        
        //[actionSheet showInView:self.view];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    
    UIView *t_view = [UIApplication sharedApplication].keyWindow;
    NSLog(@"%f %f %f %f",
          t_view.frame.origin.x,t_view.frame.origin.y,
          t_view.frame.size.width,t_view.frame.size.height);
}


#pragma mark - OCComunication Methods

///-----------------------------------
/// @name Set Credentials in OCCommunication
///-----------------------------------

/**
 * Set username and password in the OCComunicacion
 */
- (void) reloadPage{
    //Set credentials once
    BOOL tret = [self setCredencialsInOCCommunication];
    if( tret == YES ){
        // Show Data !!
        [self showFolder:nil];
    }
}

- (BOOL) setCredencialsInOCCommunication {
    
    NSString *userid = [Utils getConfigForKey:@"userid"];
    NSString *passwd = [Utils getConfigForKey:@"passwd"];
    NSString *host = [Utils getConfigForKey:@"host"];
    
    if(userid == nil || userid.length < 1
         || passwd == nil || passwd.length < 1
         || host == nil || host.length < 1){
        // Auth Infomation Not found
        // Goto Account Manager
        [self redirectloginView];
        
        return NO;
    }
    
    //Setting credencials
    [[AppDelegate sharedOCCommunication] setCredentialsWithUser:userid andPassword:passwd];
   
    return YES;
}

- (void) redirectloginView {
    [Utils setConfigForKey:@"userid" withValue:nil withSync:true];
    [Utils setConfigForKey:@"passwd" withValue:nil withSync:true];

    UIStoryboard * st =  [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AccountManagerController * vc =   [st instantiateViewControllerWithIdentifier:@"AccountManagerController"];
    vc._pv = self;
    
    [self presentViewController:vc animated:YES completion:nil];
}

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
               OCFileDto *titem = [[OCFileDto alloc] init];
               titem.fileName = folderName;
               titem.filePath = self.path;
               titem.isDirectory = YES;
               titem.date = [[NSDate date] timeIntervalSince1970];
               
               [self.itemsOfPath insertObject:titem atIndex:0];
               [self.tableView reloadData];
               //[self showFolder:nil];
           }
           failureRequest:^(NSHTTPURLResponse *response, NSError *error){
               [hud hide:YES];
               if (response.statusCode == 401){
                   [self redirectloginView];
               }
           }
           errorBeforeRequest:^(NSError *error){
               [hud hide:YES];
               [Utils showAlert:@"Create Fail" withMsg:[error localizedDescription]];
           }];
}

/**
 * This method has block to read the root folder of the specific account,
 * add the data to itemsOfPath array and reload the table view.
 */
- (void) showFolder:(UIRefreshControl *)refreshctrl {
    
    NSString *t_path = [Utils getHomeURLwithPath:self.path];
    NSLog(@"t_Path: %@", t_path);
    
    t_path = [t_path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *hud = nil;
    if(refreshctrl == nil){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        hud.labelText = @"Loading";
    }
    
    [[AppDelegate sharedOCCommunication] readFolder:t_path onCommunication:[AppDelegate sharedOCCommunication] successRequest:^(NSHTTPURLResponse *response, NSArray *items, NSString *redirected) {
        
        //Success
        if(hud == nil){
            [refreshctrl endRefreshing];
        }else{
            [hud hide:YES];
        }
        
        NSLog(@"succes");
        for (OCFileDto *itemDto in items) {
            //Check parser
            NSLog(@"Item file name: %@", itemDto.fileName);
            NSLog(@"Item file path: %@", itemDto.filePath);
        }
        
        NSMutableArray *t_array = [[NSMutableArray alloc] init];
        
        // Add Directories
        NSInteger tDirSize= 0,tFileSize=0;
        for(OCFileDto *itemDto in items){
            if(![itemDto isDirectory]){
                continue;
            }
            if(itemDto.fileName == nil){
                continue;
            }
            [t_array addObject:itemDto];
            tDirSize = tDirSize + 1;
        }
        
        // Add Files
        for(OCFileDto *itemDto in items){
            if([itemDto isDirectory]){
                continue;
            }
            if(itemDto.fileName == nil){
                continue;
            }
            [t_array addObject:itemDto];
            tFileSize = tFileSize + 1;
        }
        
        self.fileSize = tFileSize;
        self.itemsOfPath = nil;
        self.itemsOfPath = [NSMutableArray arrayWithArray:t_array];
        self.itemsOfResult = [NSMutableArray arrayWithArray:t_array];
        self.summary.text = [[NSString alloc] initWithFormat:@"%d files, %d folders", self.fileSize, self.dirSize];
        
        [self.tableView reloadData];

    } failureRequest:^(NSHTTPURLResponse *response, NSError *error) {
        //Request failure
        if(hud == nil){
            [refreshctrl endRefreshing];
        }else{
            [hud hide:YES];
        }
        if (response.statusCode == 401){
            [self redirectloginView];
        } else {
            if(self.alertView != nil){ self.alertView = nil; }
            self.alertView = [[UIAlertView alloc] initWithTitle:@"Loading Fail" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [self.alertView show];
        }
    }];
    
}



///-----------------------------------
/// @name Download file
///-----------------------------------


/*e
 * Method that upload a specific file of a specific path of ownCloud server.
 */
- (void)uploadFile:(NSString *)localPath withName:(NSString *)uploadName{
    
    // Filename
    //NSString *fileName = [localPath lastPathComponent];
    
    // Server File Path
    NSString *serverUrl = [Utils getFileURLwithPath:self.path withFileName:uploadName];
    {
        NSLog(@"Download - serverUrl = %@",serverUrl);
    }
    
    // Progress View Show
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Uploading";
 
    _uploadOperation = nil;
    _uploadOperation = [[AppDelegate sharedOCCommunication] uploadFile:localPath toDestiny:serverUrl onCommunication:[AppDelegate sharedOCCommunication]
        progressUpload:^(NSUInteger bytesWrite, long long totalBytesWrite, long long totalExpectedBytesWrite) {
            //Progress
            if(totalExpectedBytesWrite == 0){
                hud.progress = 0;
            }
            hud.progress = (float)totalBytesWrite / totalExpectedBytesWrite;
        }
        successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer) {
            //Success
            [hud hide:YES];
            [self showFolder:nil];
        }
        failureRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer, NSError *error) {
            //Request failure
            if (response.statusCode == 401){
                [self redirectloginView];
            } else {
                [hud hide:YES];
                if(self.alertView != nil){ self.alertView = nil; }
                self.alertView = [[UIAlertView alloc] initWithTitle:@"Upload Fail" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
                [self.alertView show];
            }
        }
        failureBeforeRequest:^(NSError *error) {
            [hud hide:YES];
            if(self.alertView != nil){ self.alertView = nil; }
            self.alertView = [[UIAlertView alloc] initWithTitle:@"Upload Fail" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [self.alertView show];
            //Failure before the request
        }
        shouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            [hud hide:YES];
            //Specifies that the operation should continue execution after the app has entered the background, and the expiration handler for that background task.
            [_uploadOperation cancel];
        }
    ];
}

///-----------------------------------
/// @name Delete file
///-----------------------------------

/**
 * This method delete the uploaded file in the ownCloud server
 */
- (void) deleteFile:(SWTableViewCell *)cell{
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    OCFileDto *itemDto = [[self itemsOfPath] objectAtIndex:cellIndexPath.row];
    
    // Make Folder Path
    NSString *t_path = [Utils getFileURLwithPath:self.path withFileName:itemDto.fileName];
    NSString *t_local_path = [Utils getCacheFileWithPath:self.path withFileName:itemDto.fileName];
    
    // Create Folder;
    NSLog(@"path info = %@",t_path);
    
    MBProgressHUD *hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Delete....";

    //Delete Block
    
    [[AppDelegate sharedOCCommunication] deleteFileOrFolder:t_path onCommunication:[AppDelegate sharedOCCommunication]
         successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer)
         {
            //Success
            [hud hide:YES];

            // Delete Cell
            [self.itemsOfPath removeObjectAtIndex:cellIndexPath.row];
            NSArray *deleteIndexPaths = [NSArray arrayWithObjects:cellIndexPath,nil];
            [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
             
             // Delete Local Cache
            NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:t_local_path error:&terror];
             
             
         } failureRquest:^(NSHTTPURLResponse *resposne, NSError *error)
         {
             //Failure
            [hud hide:YES];
            
             [Utils showAlert:@"Delete Faile" withMsg:[error localizedDescription]];
             
         }
     ];
}
- (void) shareLink:(SWTableViewCell *)cell{
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    OCFileDto *itemDto = [[self itemsOfPath] objectAtIndex:cellIndexPath.row];
    
    // Make Folder Path
    NSString *t_server_path = [Utils getHomeURLwithPath:@""];
    NSString *t_file_path = [NSString stringWithFormat:@"%@%@",[itemDto.filePath stringByReplacingOccurrencesOfString:PathPrefix withString:@""],itemDto.fileName];
    
    {
        NSLog(@"t_server_path = %@",t_server_path);
        NSLog(@"t_file_path = %@",t_file_path);
    }
    
    MBProgressHUD *hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Share Link....";

    //Delete Block
    [[ AppDelegate sharedOCCommunication ] shareFileOrFolderByServer :t_server_path andFileOrFolderPath :t_file_path onCommunication :[ AppDelegate sharedOCCommunication ]
      successRequest :^( NSHTTPURLResponse *response, NSString *token, NSString *redirectedServer) {
          [hud hide:YES];
         
          NSString *t_path = [[NSString alloc] initWithFormat:@"%@/public.php?service=files&t=%@",[Utils getConfigForKey:@"host"],token];
          
          UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[t_path] applicationActivities:nil];
          if(IS_IPAD && IS_OS_8_OR_LATER){
              activityView.popoverPresentationController.sourceView = [self view];
          }
          [self presentViewController:activityView animated:YES completion:^{
              [cell hideUtilityButtonsAnimated:YES];
          }];
          //--------------------------
          
          //[Utils showAlert:@"Share Link" withMsg:@"Success"];
      }
      failureRequest :^( NSHTTPURLResponse *response, NSError *error){
          if (response.statusCode == 401){
              [self redirectloginView];
          } else {
              [hud hide:YES];
              [Utils showAlert:@"File View Error" withMsg:[error localizedDescription]];
          }
      }];
}
- (void) renameWith:(OCFileDto *)fileDto withNewName:(NSString *)newName
{
    NSString *basePath = [Utils getHomeURLwithPath:self.path];
    NSString *fromPath = [basePath stringByAppendingString:[fileDto.fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *toPath = [basePath stringByAppendingString:[newName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
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
    hud.labelText = @"Rename....";

   
    [[AppDelegate sharedOCCommunication] moveFileOrFolder:fromPath toDestiny:toPath onCommunication:[AppDelegate sharedOCCommunication]
       successRequest:^(NSHTTPURLResponse *response, NSString *redirectServer){
           [hud hide:YES];
           fileDto.fileName = newName;
           [self.tableView reloadData];
       }
       failureRequest:^(NSHTTPURLResponse *response, NSError *error){
           if (response.statusCode == 401){
               [self redirectloginView];
           } else {
               [hud hide:YES];
               [Utils showAlert:@"Rename Error" withMsg:[error localizedDescription]];
           }
       }
       errorBeforeRequest:^(NSError *error){
           [hud hide:YES];
           [Utils showAlert:@"Rename Error" withMsg:[error localizedDescription]];
       }];
}

#pragma mark - Close View


- (IBAction)closeView:(id)sender{
    
    //if there are a operation in progress cancel
    
    //if upload operation in progress
    if (_uploadOperation) {
        [_uploadOperation cancel];
        _uploadOperation = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITableView DataSource

- (void)toggleCells:(UIRefreshControl*)refreshControl
{
    
    [refreshControl beginRefreshing];
    
    [self showFolder:refreshControl];
    //[refreshControl endRefreshing];
}


// Asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (int)doFavorite:(NSString *)filePath fileUrl:(NSString *)fileUrl{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *favContext = [appDelegate favContext];
    Favorite *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:favContext];
    NSError *error;
    NSString *uid = [Utils getConfigForKey:@"userid"];
    NSArray *fav = [self changeFrc:filePath fileUrl:fileUrl uid:uid];
    
    if ([fav count] > 0) {
        favorite = [fav objectAtIndex:0];
        [favContext deleteObject:favorite];
    }else{
        favorite.filePath = filePath;
        favorite.fileUrl = fileUrl;
        favorite.uid = uid;
    }
    
    if ([favContext save:&error]) {
        NSArray *fav = [self changeFrc:filePath fileUrl:fileUrl uid:uid];
        return [fav count];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return 0;
    }
    return 0;
}

-(NSArray *)changeFrc:(NSString *)filePath fileUrl:(NSString *)fileUrl uid:(NSString *)uid {
    //Favorite 조회
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *favFetch = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *favContext = [appDelegate favContext];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    
    
    favFetch.entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:favContext];
    favFetch.predicate = [NSPredicate predicateWithFormat:@"filePath == %@ && uid == %@",filePath,uid];
    favFetch.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error = nil;
    NSArray *fav = [favContext executeFetchRequest:favFetch error:&error];
    
    
    if (error) {
        NSLog(@"Failed to fetch objects: %@",[error description]);
    }
    return fav;
}

-(void)toggleFavorite:(FilesViewCell *)cell count:(int) cnt{
    if(cnt > 0) {
        cell.favoriteImage.image = [UIImage imageNamed:@"star.png"];
    }else{
        cell.favoriteImage.image = nil;
    }
}

// Returns the table view managed by the controller object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCFileDto *itemDto = nil;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        itemDto = [self.itemsOfResult objectAtIndex:indexPath.row];
    }else{
        itemDto = [self.itemsOfPath objectAtIndex:indexPath.row];
    }
    
    static NSString *CellIdentifier = @"DefaultCell";
    
    FilesViewCell *cell = (FilesViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.delegate = self;
    [cell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:50];
    
    [cell sizeToFit];

    cell.name.text = [itemDto.fileName stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];

    if(itemDto.isDirectory){
        UIImage *t_image = [UIImage imageNamed:@"folder.png"];
        CGSize vsize = cell.image.bounds.size;
        CGSize isize = t_image.size;
        
        NSLog(@"vsize=%fx%f, isize=%fx%f",vsize.width,vsize.height,isize.width,isize.height);
        
        cell.image.image = [UIImage imageNamed:@"folder.png"];
        cell.cacheImage.image = nil;
        cell.favoriteImage.image = nil;
        cell.prop.text = [[NSString alloc] initWithFormat:@"%@", [Utils timeAgoString:itemDto.date]];
    }else{
        cell.image.image = [UIImage imageNamed:[[AppDelegate sharedUtilExtension] getIconName:itemDto.fileName]];
        NSLog(@"cell_image=%@,%@",cell.image.image,cell.image);
        
        NSString *localfile = [Utils getCacheFileWithPath:itemDto.filePath withFileName:itemDto.fileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:localfile]){
            cell.cacheImage.image = [UIImage imageNamed:@"save.png"];
        }
        
        //Favorite
        NSString *filePath = [NSString stringWithFormat:@"%@%@",[itemDto.filePath stringByReplacingOccurrencesOfString:PathPrefix withString:@""],itemDto.fileName];
        NSString *fileUrl = [Utils getFileURLwithPath:itemDto.filePath withFileName:itemDto.fileName];
        NSArray *fav = [self changeFrc:filePath fileUrl:fileUrl uid:[Utils getConfigForKey:@"userid"]];
        [self toggleFavorite:cell count:[fav count]];
        
        //Share Link Read
        if ([self isInSharedExist:filePath]) {
            cell.shareImage.image = [UIImage imageNamed:@"link.png"];
        }
        cell.prop.text = [[NSString alloc] initWithFormat:@"%@, %@",[Utils timeAgoString:itemDto.date],[Utils humanReadableSize:itemDto.size]];
    }
    
    return cell;
}
- (BOOL) isInSharedExist:(NSString *) path {
    if (self.sharedCurPath.count > 0) {
        for (int i = 0; i<self.sharedCurPath.count; i++) {
            OCSharedDto *dto = [self.sharedCurPath objectAtIndex:i];
            if([dto.path isEqualToString:path] && dto.shareType == 3){
                return true;
            }
        }
    }
    return false;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:0.88f green:0.88f blue:0.9f alpha:1.0] icon:[UIImage imageNamed:@"more.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] icon:[UIImage imageNamed:@"link.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete.png"]];
    
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
    OCFileDto *itemDto = nil;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        itemDto = [self.itemsOfResult objectAtIndex:indexPath.row];
    }else{
        itemDto = [self.itemsOfPath objectAtIndex:indexPath.row];
    }
    
    if(itemDto.isDirectory){
        NSLog(@"Selected Row is = %ld",(long)indexPath.row);
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        FilesViewController *fvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FilesViewRoot"];
        
        
        if(self.path == nil){
            fvc.path = [[NSString alloc] initWithFormat:@"%@",itemDto.fileName];
        }else{
            fvc.path = [[NSString alloc] initWithFormat:@"%@/%@",self.path, itemDto.fileName];
        }
        
        [[self navigationController] pushViewController:fvc animated:YES];
        return;
    }else{
        // Show File
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DataViewController *dataViewer = [mainStoryboard instantiateViewControllerWithIdentifier:@"FilesDataViewer"];
        [dataViewer setFileItem:itemDto];
        [dataViewer setPcontrol:self];
        [dataViewer setCell:[self.tableView cellForRowAtIndexPath:indexPath]];
         
        [self presentViewController:dataViewer animated:YES completion:nil];
    }
}

// Returns the table view managed by the controller object.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.itemsOfResult count];
    }else{
        if (!self.itemsOfPath) {
            return 0;
        } else {
            return [self.itemsOfPath count];
        }
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    OCFileDto *itemDto = [[self itemsOfPath] objectAtIndex:cellIndexPath.row];
    self.currItem = itemDto;
    self.currCell = (FilesViewCell *)cell;
    
    switch (index) {
        case 0:
        {
            // More Button
            UIActionSheet *actionSheet = nil;
            if(itemDto.isDirectory){
                actionSheet = [[UIActionSheet alloc]
                                initWithTitle:@"More"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Rename",@"Move",nil];
            }else{
                actionSheet = [[UIActionSheet alloc]
                                initWithTitle:@"More"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Open with",@"Rename",@"Move",@"Favorite",nil];
            }

            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // ShareLink Button
            [self shareLink:cell];
            
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 2:
        {
            // Delete button was pressed
            [self deleteFile:cell];
            break;
        }
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"Right button 0 was pressed");
            break;
        case 1:
            NSLog(@"Right button 1 was pressed");
            break;
        case 2:
            NSLog(@"Right button 2 was pressed");
            break;
        case 3:
            NSLog(@"Right btton 3 was pressed");
        default:
            break;
    }
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


- (void)executeCommand:(NSString *)title {
    if([title isEqualToString:@"New folder"]){
        // Input new Folder Name
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"디렉터리 이름 입력"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
        
        [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [message show];
    }else if([title isEqualToString:@"Upload Photo/Video"]){
        // Picture Select
        
        // Create the image picker
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        elcPicker.maximumImagesCount = [[Utils getPlistConfigForKey:@"upload_max"] intValue]; //Set the maximum number of images to select, defaults to 4
        elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
        elcPicker.imagePickerDelegate = self;
        
        //Present modally
        [self presentViewController:elcPicker animated:YES completion:nil];
        
    }else if([title isEqualToString:@"Rename"]){
        if(self.currItem == nil){
            return;
        }
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Rename"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
        
        [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[message textFieldAtIndex:0] setText:[self.currItem.fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [message show];
    }else if([title isEqualToString:@"Move"]){
        // Move
        if(self.currItem == nil){
            return;
        }
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ChooseFolderViewController *fvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChooseFolderViewController"];
        fvc.parent = self;
        
        UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChooseFolderNavigation"];
        [nc setViewControllers:@[fvc]];
        [self presentViewController:nc animated:YES completion:^(void){
        }];
    }else if([title isEqualToString:@"Open with"]){
        // Cache Directory Setting
        NSError * terror = nil;
        NSString *cacheDir = [Utils getCacheDirWithPath:self.currItem.filePath];
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&terror];
        self.localFileName = [[cacheDir stringByAppendingString:@"/"] stringByAppendingString:self.currItem.fileName];
        self.localTempFileName = [[[cacheDir stringByAppendingString:@"/"] stringByAppendingString:self.currItem.fileName] stringByAppendingString:@".temp"];
        {
            NSLog(@"Download - cacheDir = %@",cacheDir);
            NSLog(@"Download - localfile = %@",self.localFileName);
        }
        
        // Check Cache files
        if([[NSFileManager defaultManager] fileExistsAtPath:self.localFileName]){
            // ShowOpenWith
            [self showOpenWith];
            return;
        }
        
        // Server File Path
        NSString *serverUrl = [Utils getFileURLwithPath:self.currItem.filePath withFileName:self.currItem.fileName];
        {
            NSLog(@"Download - serverUrl = %@",serverUrl);
        }
        
        // Progress
        CGRect pbounds = self.view.frame;
        CGPoint os = [self.tableView contentOffset];
        CGRect frame = CGRectMake(pbounds.size.width/2-85,pbounds.size.height/2-44+os.y,170,44);
        UIView *t_view = [[UIView alloc] initWithFrame:frame];
        [t_view setBackgroundColor:[UIColor whiteColor]];
        [t_view setAlpha:0.8];
        
        float borderWidth = 1.0f;
        frame = t_view.frame;
        frame.size.width += borderWidth;
        frame.size.height += borderWidth;
        t_view.layer.borderColor = [UIColor blackColor].CGColor;
        t_view.layer.borderWidth = borderWidth;
        
        self.progressView = t_view;
        
        
        frame = CGRectMake(10,20,100,4);
        UIProgressView *t_prog = [[UIProgressView alloc] initWithFrame:frame];
        t_prog.progress = 0;
        frame = CGRectMake(130,12,30,20);
        UIButton *t_button = [[UIButton alloc] initWithFrame:frame];
        [t_button setTitle:@"X" forState:UIControlStateNormal];
        t_button.titleLabel.textColor = [UIColor blackColor];
        [t_button addTarget:self action:@selector(stopDownload:)forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:t_view];
        [t_view addSubview:t_prog];
        [t_view addSubview:t_button];
        
        [self.view bringSubviewToFront:t_view];
        
        self._downloadOperation = nil;
        self._downloadOperation = [[AppDelegate sharedOCCommunication] downloadFile:serverUrl toDestiny:self.localTempFileName withLIFOSystem:YES onCommunication:[AppDelegate sharedOCCommunication]
                                                                   progressDownload:^(NSUInteger bytesRead, long long totalBytesRead, long long totalExpectedBytesRead) {
                                                                       // Progress
                                                                       if(totalExpectedBytesRead == 0){
                                                                           t_prog.progress = 0;
                                                                       }
                                                                       t_prog.progress = (float)totalBytesRead / totalExpectedBytesRead;
                                                                       
                                                                   } successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer) {
                                                                       // Success
                                                                       NSError *terror; [[NSFileManager defaultManager] moveItemAtPath:self.localTempFileName toPath:self.localFileName error:&terror];
                                                                       [t_view removeFromSuperview];
                                                                       [self showOpenWith];
                                                                       
                                                                   } failureRequest:^(NSHTTPURLResponse *response, NSError *error) {
                                                                       [t_view removeFromSuperview];
                                                                       NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:self.localTempFileName error:&terror];
                                                                       if (response.statusCode == 401){
                                                                           [self redirectloginView];
                                                                       }
                                                                       // Request failure
                                                                       if(error.code != -999){
                                                                           [Utils showAlert:@"Download Fail" withMsg:[error localizedDescription]];
                                                                       }
                                                                   } shouldExecuteAsBackgroundTaskWithExpirationHandler:^{
                                                                       [t_view removeFromSuperview];
                                                                       [self._downloadOperation cancel];
                                                                       NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:self.localTempFileName error:&terror];
                                                                   }];
        
        
        
    }else if([title isEqualToString:@"Favorite"]){
        NSString *filePath = [NSString stringWithFormat:@"%@%@",[self.currItem.filePath stringByReplacingOccurrencesOfString:PathPrefix withString:@""],self.currItem.fileName];
        NSString *fileUrl = [Utils getFileURLwithPath:self.currItem.filePath withFileName:self.currItem.fileName];
        int cnt = [self doFavorite:filePath fileUrl:fileUrl];
        [self toggleFavorite:self.currCell count:cnt];
    }
}


#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    [self executeCommand:title];
}

-(IBAction)stopDownload:(id)sender
{
    // Operation Stop
    [self._downloadOperation cancel];
    
    NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:self.localTempFileName error:&terror];

    // Hide Progress
    [self.progressView removeFromSuperview];
}

-(void)showOpenWith
{
    UtilFileType type = [[AppDelegate sharedUtilExtension] getFileType:self.localFileName];
    switch (type) {
        case kFileTypeImage:{
            UIImage* image = [UIImage imageWithContentsOfFile:self.localFileName];
            NSArray* actItems = [NSArray arrayWithObjects:image, nil];
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
            if(IS_IPAD && IS_OS_8_OR_LATER){
                activityView.popoverPresentationController.sourceView = [self view];
            }
            [self presentViewController:activityView animated:YES completion:^{
            }];
        }break;
        case kFileTypePdf:
        case kFileTypeText:
        case kFileTypeAudio:
        case kFileTypeOffice:
        case kFileTypeMPEG4:
        default:{
            NSData *data = [NSData dataWithContentsOfFile:self.localFileName];
            NSArray* actItems = [NSArray arrayWithObjects:data, nil];
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
            if(IS_IPAD && IS_OS_8_OR_LATER){
                activityView.popoverPresentationController.sourceView = [self view];
            }
            [self presentViewController:activityView animated:YES completion:nil];
        }
        break;
    } 
}

#pragma mark - AlertView Delegate
// ------------------------------------------------------------------------------------------
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
    }else if([title isEqualToString:@"Rename"]){
        if([bt_title isEqualToString:@"OK"])
        {
            UITextField *newName = [alertView textFieldAtIndex:0];
            [self renameWith:self.currItem withNewName:[newName text]];
        }
    }else if([title isEqualToString:@"NCDrive Updated"]){
        if ([bt_title isEqualToString:@"Yes"]) {
            NSURL* url = [[NSURL alloc] initWithString:[Utils getPlistConfigForKey:@"appDownloadUrl"]];
            [[UIApplication sharedApplication] openURL:url];
        } else if([bt_title isEqualToString:@"No"]) {
            dissmissAppupdate = true;
        }
    }
}

#pragma mark - UIImagePicker Delegate
// ------------------------------------------------------------------------------------------
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (info.count < 1) return;
    
    for(NSDictionary *data in info){
        
        UIImage *t_image = [data valueForKey:UIImagePickerControllerOriginalImage];
        NSData *t_img_data = UIImageJPEGRepresentation(t_image, 1);
        NSString *t_image_path = [Utils getTempFile];
        NSURL *t_img_url = [data objectForKey:UIImagePickerControllerReferenceURL];
        [t_img_data writeToFile:t_image_path atomically:YES];
        
        
        // define the block to call when we get the asset based on the url (below)
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
        {
            ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
            NSString *t_filename = [imageRep filename];
            NSString *t_server_url = [Utils getFileURLwithPath:self.path withFileName:t_filename];
            
            
            {
                // Debug
                NSLog(@"t_img_url=%@",t_img_url);
                NSLog(@"t_filename=%@",t_filename);
                NSLog(@"t_server_url=%@",t_server_url);
            }
            
            
            UploadObject *obj_upload = [[UploadObject alloc] init];
            obj_upload.fileName = t_filename;
            obj_upload.filePath = self.path;
            obj_upload.size = [NSNumber numberWithInteger:t_img_data.length ];
            obj_upload.date = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            NSProgress *progress = obj_upload.progress;

            [[AppDelegate sharedUploadData].current addObject:obj_upload];
            
            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
            item.badgeValue = [NSString stringWithFormat:@"%d",[AppDelegate sharedUploadData].current.count];
            
            obj_upload.uploadTask = [[AppDelegate sharedOCCommunication] uploadFileSession:t_image_path toDestiny:t_server_url
                                                                onCommunication:[AppDelegate sharedOCCommunication] withProgress:&progress
            successRequest:^(NSURLResponse *response, NSString *redirectedServer) {
                //Success
                //Remove the local file
                
                OCFileDto *titem = [[OCFileDto alloc] init];
                titem.filePath = obj_upload.filePath;
                titem.fileName = obj_upload.fileName;
                titem.size = [obj_upload.size longValue];
                titem.date = [obj_upload.date longValue];
                titem.isDirectory = NO;
                
                [self.itemsOfPath insertObject:titem atIndex:[self.itemsOfPath count]];
                [self.tableView reloadData];
                
                NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:t_image_path error:&terror];
                [[AppDelegate sharedUploadData].current removeObject:obj_upload];
                [[AppDelegate sharedUploadData].uploader addObject:obj_upload];
                [[AppDelegate sharedUploadData] addReloadCnt:1];
                
                NSInteger cnt = [AppDelegate sharedUploadData].current.count;
                if(cnt > 0){
                    item.badgeValue = [NSString stringWithFormat:@"%d",cnt];
                }else{
                    item.badgeValue = nil;
                }
                
            } failureRequest:^(NSURLResponse *response, NSString *redirectedServer, NSError *error) {
                
                [[AppDelegate sharedUploadData].current removeObject:obj_upload];
                if(error.code != -999){ // -999 is Cancel
                    obj_upload.errMsg = [error localizedDescription];
                    [[AppDelegate sharedUploadData].failed addObject:obj_upload];
                }
                [[AppDelegate sharedUploadData] addReloadCnt:1];
                NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:t_image_path error:&terror];
                NSLog(@"upload error: %@", error);
                if (error.code == 401){
                    [self redirectloginView];
                }
                
                NSInteger cnt = [AppDelegate sharedUploadData].current.count;
                if(cnt > 0){
                    item.badgeValue = [NSString stringWithFormat:@"%d",cnt];
                }else{
                    item.badgeValue = nil;
                }
                
            } failureBeforeRequest:^(NSError *error) {
                //Failure before Request
                
                [[AppDelegate sharedUploadData].current removeObject:obj_upload];
                NSError *terror; [[NSFileManager defaultManager] removeItemAtPath:t_image_path error:&terror];
                NSLog(@"error while upload a file: %@", error);
                [[AppDelegate sharedUploadData] addReloadCnt:1];
                
                NSInteger cnt = [AppDelegate sharedUploadData].current.count;
                if(cnt > 0){
                    item.badgeValue = [NSString stringWithFormat:@"%d",cnt];
                }else{
                    item.badgeValue = nil;
                }
            }];
            obj_upload.progress = progress;
        };
        
        // get the asset library and fetch the asset based on the ref url (pass in block above)
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:t_img_url resultBlock:resultblock failureBlock:nil];
    }
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.itemsOfResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self.fileName contains[c] %@", searchText];
    self.itemsOfResult = [NSMutableArray arrayWithArray: [self.itemsOfPath filteredArrayUsingPredicate:resultPredicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                                scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                objectAtIndex:[self.searchDisplayController.searchBar
                                selectedScopeButtonIndex]]];
    return YES;
}
@end
