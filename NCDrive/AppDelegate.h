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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (OCCommunication*)sharedOCCommunication;
+ (UploadData *)sharedUploadData;
+ (State *)sharedState;
+ (UtilExtension *)sharedUtilExtension;
- (void)resetViews;
@end

