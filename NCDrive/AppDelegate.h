//
//  AppDelegate.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 12..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCommunication.h"
#import "UploadObject.h"
#import "State.h"
#import "Utils.h"
#import "FavoriteDocument.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    FavoriteDocument *_favDocument;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , retain) NSManagedObjectContext *favContext;

+ (OCCommunication*)sharedOCCommunication;
+ (UploadData *)sharedUploadData;
+ (State *)sharedState;
+ (UtilExtension *)sharedUtilExtension;
+ (NSManagedObjectContext *)sharedFav;
- (void)resetViews;
@end

