//
//  DataViewController.h
//
//  Created by JangJaeMan on 2014. 8. 3..
//

#import <UIKit/UIKit.h>
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCFileDto.h"
#import "Favorite.h"

typedef void(^SuccessCallback)(NSString *filename);
typedef void(^ErrorCallback)(NSError *err);

@interface DataViewController : UIViewController <UIAlertViewDelegate> {
}

@property (nonatomic,strong) IBOutlet UIImageView *imgView;
@property (nonatomic,strong) IBOutlet UIWebView *webView;
@property (nonatomic,strong) OCFileDto *fileItem;
@property (nonatomic,strong) NSString *localFileName;
@property (nonatomic,strong) NSString *localTempFileName;
@property (nonatomic,strong) id pcontrol;
@property (nonatomic,strong) id cell;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *fileUrl;
@property (nonatomic,strong) NSString *uid;


@property (nonatomic,strong) IBOutlet UINavigationBar *topToolBar;
@property (nonatomic,strong) IBOutlet UIToolbar *botToolBar;
@property (nonatomic,strong) IBOutlet UIProgressView *downloadProgress;
@property (nonatomic,strong) IBOutlet UIView *stateView;
@property (nonatomic,strong) IBOutlet UIView *fileicondView;
@property (nonatomic,strong) IBOutlet UIImageView *fileiconImage;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *favoriteBtn;

// Operation
@property(nonatomic,strong)NSOperation *downloadOperation;

//FavoriteDATA
@property (nonatomic,retain) NSFetchedResultsController *frc;

// Action
-(IBAction) doAction:(id)sender;
-(IBAction) doClose:(id)sender;
-(IBAction) doFavorite:(id)sender;
-(IBAction) doDelete:(id)sender;
-(IBAction) doCancel:(id)sender;
-(IBAction) doLink:(id)sender;


@end
