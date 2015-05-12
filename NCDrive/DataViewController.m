//
//  DataViewController.m
//
//  Created by JangJaeMan on 2014. 8. 3..
//

#import "DataViewController.h"
#import "FilesViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface DataViewController ()

@end

@implementation DataViewController

@synthesize fileItem;
@synthesize webView;
@synthesize imgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topToolBar.autoresizingMask = self.topToolBar.autoresizingMask | UIViewAutoresizingFlexibleHeight;
    self.botToolBar.autoresizingMask = self.botToolBar.autoresizingMask | UIViewAutoresizingFlexibleHeight;
    
    NSLog(@"statView:%@",self.stateView);
    NSLog(@"topToolBar:%@",self.topToolBar);
    
    
    self.downloadProgress.progress = 0;
    
    // Set Title
    [[[self topToolBar] topItem] setTitle:[self.fileItem.fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    // Cache Directory Setting
	NSError * terror = nil;
    NSString *cacheDir = [Utils getCacheDirWithPath:self.fileItem.filePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&terror];
    self.localFileName = [Utils getCacheFileWithPath:self.fileItem.filePath withFileName:self.fileItem.fileName];
    self.localTempFileName = [Utils getTempFile];
    self.filePath = [NSString stringWithFormat:@"%@%@",[self.fileItem.filePath stringByReplacingOccurrencesOfString:PathPrefix withString:@""],self.fileItem.fileName];
    self.fileUrl = [Utils getFileURLwithPath:self.fileItem.filePath withFileName:self.fileItem.fileName];
    self.uid = [Utils getConfigForKey:@"userid"];

    [self changeFrc];
    [self toggleFavorite];
    {
		NSLog(@"Download - cacheDir = %@",cacheDir);
		NSLog(@"Download - localfile = %@",self.localFileName);
		NSLog(@"Download - tempfile = %@",self.localTempFileName);
	}
    
    self.fileiconImage.image = [UIImage imageNamed:[[AppDelegate sharedUtilExtension] getIconName:self.fileItem.fileName]];
    
    UtilFileType type = [[AppDelegate sharedUtilExtension] getFileType:self.fileItem.fileName];
    switch (type) {
        case kFileTypeImage:
        case kFileTypePdf:
        case kFileTypeText:
        case kFileTypeAudio:
        case kFileTypeOffice:
        case kFileTypeMPEG4:{
            [self downloadFile:NO withAction:NO];
        }break;
        case kFileTypeOtherVideo:{
            [self downloadFile:YES withAction:NO];
        }break;
        default:{
            [self.stateView setHidden:YES];
        } break;
    }
    
    //Delete Confirm
    UIBarButtonItem *bbtnConfirmDelete = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(doDelete:)];
    self.navigationItem.rightBarButtonItem = bbtnConfirmDelete;
    
    //favoriteImage
    [self toggleFavorite];
}

- (void)showData:(NSString *)localpath {
	[self.stateView setHidden:YES];
    [self.fileicondView setHidden:YES];
   
    UtilFileType type = [[AppDelegate sharedUtilExtension] getFileType:localpath];
    switch (type) {
        case kFileTypeImage:{
			[self.webView setHidden:YES];
			[self.imgView setImage:[UIImage imageWithContentsOfFile:localpath]];
        }break;
        case kFileTypePdf:
        case kFileTypeText:
        case kFileTypeAudio:
        case kFileTypeOffice:
        case kFileTypeOtherVideo:
        case kFileTypeMPEG4:{
			[self.imgView setHidden:YES];
            NSURL *targetURL = [NSURL fileURLWithPath:localpath];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [self.webView loadRequest:request];
        }break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

- (IBAction) doClose:(id)sender
{
   if (_downloadOperation) {
        [_downloadOperation cancel];
        _downloadOperation = nil;
       
        //Remove download file
        //[self deleteDownloadedFile:nil];
    }

    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.pcontrol isKindOfClass:[FilesViewController class]]) {
            FilesViewController *fvc = (FilesViewController *) self.pcontrol;
            [fvc resetSwipeCells];
        }
    }];
}

- (IBAction) doAction:(id)sender{
    
    UtilFileType type = [[AppDelegate sharedUtilExtension] getFileType:self.localFileName];
    switch (type) {
        case kFileTypeImage:
        case kFileTypePdf:
        case kFileTypeText:
        case kFileTypeAudio:
        case kFileTypeOffice:
        case kFileTypeOtherVideo:
        case kFileTypeMPEG4:{
            [self.stateView setHidden:NO];
            [self downloadFile:NO withAction:YES];
        }break;
        default:
            break;
    }
}

-(void) actionProcess
{
	[self.stateView setHidden:YES];
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
            /*
        case kFileTypeText:{
            NSData *data = [NSData dataWithContentsOfFile:self.localFileName];
            NSArray* actItems = [NSArray arrayWithObjects:data, nil];
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
                [self presentViewController:activityView animated:YES completion:^{
            }];
        }break;
             */
        case kFileTypeText:
        case kFileTypePdf:
        case kFileTypeAudio:
        case kFileTypeMPEG4:
        case kFileTypeOtherVideo:
        case kFileTypeOffice:
        default:{
            NSURL *targetURL = [NSURL fileURLWithPath:self.localFileName];
            //NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            //NSData *data = [NSData dataWithContentsOfFile:self.localFileName];
            NSArray* actItems = [NSArray arrayWithObjects:targetURL, nil];
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
            if(IS_IPAD && IS_OS_8_OR_LATER){
                activityView.popoverPresentationController.sourceView = [self view];
            }
            [self presentViewController:activityView animated:YES completion:nil];
        } break;
    }
}

- (IBAction) doCancel:(id)sender
{
    if (_downloadOperation) {
        [_downloadOperation cancel];
        _downloadOperation = nil;
       
        
        //Remove download file
        NSString *localfile = [Utils getCacheFileWithPath:self.fileItem.filePath withFileName:self.fileItem.fileName];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error;
        if ([fileMgr removeItemAtPath:localfile error:&error] != YES){
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
    }
}

- (IBAction) doDelete:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Delete it really?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        [self.pcontrol deleteFile:(SWTableViewCell *)self.cell];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)doFavorite:(id)sender{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *favContext = [appDelegate favContext];
    Favorite *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:favContext];
    NSError *error;
    NSString *msgTitle;
    
    if (self.frc != nil && [self countFavorite] > 0) {
        NSIndexPath *idPath = [NSIndexPath indexPathForRow:0 inSection:0];
        favorite = [self.frc objectAtIndexPath:idPath];
        [favContext deleteObject:favorite];
        msgTitle = @"Favorite Deleted";
    }else{
        favorite.filePath = self.filePath;
        favorite.fileUrl = self.fileUrl;
        favorite.uid = self.uid;
        msgTitle = @"Favorite Saved";
    }

    if ([favContext save:&error]) {
        [self changeFrc];
        [[[UIAlertView alloc] initWithTitle:@"Favorite" message:msgTitle delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    [self toggleFavorite];
}

-(NSFetchedResultsController *)changeFrc {
    //Favorite 조회
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *favFetch = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *favContext = [appDelegate favContext];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    
    favFetch.entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:favContext];
    favFetch.predicate = [NSPredicate predicateWithFormat:@"filePath == %@ && uid == %@",self.filePath,self.uid];
    favFetch.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error = nil;
    //NSArray *fav = [favContext executeFetchRequest:favFetch error:&error];    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:favFetch managedObjectContext:favContext sectionNameKeyPath:nil cacheName:@"OWNCLOUD_FAVORITE"];
    [frc performFetch:&error];
    self.frc = frc;

    if (error) {
        NSLog(@"Failed to fetch objects: %@",[error description]);
    }
    return frc;
}

-(int)countFavorite{
    id section = [[self.frc sections] objectAtIndex:0];
    return [section numberOfObjects];
}

-(void)toggleFavorite {
    [self changeFrc];
    
    if([self countFavorite] > 0) {
        self.favoriteBtn.image = [UIImage imageNamed:@"favoriteSelected_30.png"];
    }else{
        self.favoriteBtn.image = [UIImage imageNamed:@"favorite_30.png"];
    }
}

- (IBAction)doLink:(id)sender
{
	// Make Folder Path
	NSString *t_server_path = [Utils getHomeURLwithPath:@""];
	NSString *t_file_path = [NSString stringWithFormat:@"%@%@",[self.fileItem.filePath stringByReplacingOccurrencesOfString:PathPrefix withString:@""],self.fileItem.fileName];

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
        }[self presentViewController:activityView animated:YES completion:^{
         //   [cell hideUtilityButtonsAnimated:YES];
        }];
        
		//[Utils showAlert:@"Share Link" withMsg:@"Success"];
	}
	failureRequest :^( NSHTTPURLResponse *response, NSError *error){
		[hud hide:YES];
		[Utils showAlert:@"Share Link Error" withMsg:[error localizedDescription]];
	}];
}


/**
 * Method that download a specific file to the system Document directory
 */
- (IBAction)downloadForce:(id)sender
{
    self.downloadProgress.progress = 0;
	[self.stateView setHidden:NO];
    [self downloadFile:YES withAction:NO];
}

- (void)downloadFile:(BOOL)force withAction:(BOOL)action{
    
    // Check Cache files
    NSLog(@"downloadFile ---------------- %@",self.localFileName);
    if(force == NO && [[NSFileManager defaultManager] fileExistsAtPath:self.localFileName]){
		// Cache File Exist !!!!
        if(action == YES){
          [self actionProcess];
        }else{
          [self showData:self.localFileName];
        }
        return;
    }
    
    // Server File Path
    NSString *serverUrl = [Utils getFileURLwithPath:self.fileItem.filePath withFileName:self.fileItem.fileName];
    NSLog(@"Download - serverUrl = %@",serverUrl);
    
    _downloadOperation = nil;
    _downloadOperation = [[AppDelegate sharedOCCommunication] downloadFile:serverUrl toDestiny:self.localTempFileName withLIFOSystem:YES onCommunication:[AppDelegate sharedOCCommunication]
          progressDownload:^(NSUInteger bytesRead, long long totalBytesRead, long long totalExpectedBytesRead) {
              // Progress
              if(totalExpectedBytesRead == 0){
                  self.downloadProgress.progress = 0;
              }
              self.downloadProgress.progress = (float)totalBytesRead / totalExpectedBytesRead;
              
          } successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer) {
              // Success
              NSError *terror;
              
              if([[NSFileManager defaultManager] fileExistsAtPath:self.localFileName]){
                  [[NSFileManager defaultManager] removeItemAtPath:self.localFileName error:nil];
              }
              [[NSFileManager defaultManager] moveItemAtPath:self.localTempFileName toPath:self.localFileName error:&terror];
              NSLog(@"mmmmmmmmmmmmmm - -- - - - %@",[terror localizedDescription]);
              if(action == YES){
                  [self actionProcess];
              }else{
                  [self showData:self.localFileName];
              }
              
              [self.stateView setHidden:YES];
          } failureRequest:^(NSHTTPURLResponse *response, NSError *error) {
              // Request failure
              if(error.code != -999){
                  [Utils showAlert:@"Download Fail" withMsg:[error localizedDescription]];
              }
              [self doClose:nil];
              [self.stateView setHidden:YES];
              NSLog(@"error while download a file: %@", error);
          } shouldExecuteAsBackgroundTaskWithExpirationHandler:^{
              //Specifies that the operation should continue execution after the app has entered the background, and the expiration handler for that background task.
              [_downloadOperation cancel];
              [self.stateView setHidden:YES];
      }];
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
