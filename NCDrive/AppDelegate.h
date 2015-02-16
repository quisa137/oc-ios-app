//
//  AppDelegate.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 12..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCCommunication.h"
#import "UploadObject.h"
#import "State.h"
#import "Utils.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSManagedObjectContext *_favContext;
    NSManagedObjectModel *_favObjModel;
    NSPersistentStoreCoordinator *_favPsc;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, retain, nonatomic) NSManagedObjectContext *favContext;
@property (readonly, strong, retain, nonatomic) NSManagedObjectModel *favObjModel;
@property (readonly, strong, retain, nonatomic) NSPersistentStoreCoordinator *favPsc;

+ (OCCommunication*)sharedOCCommunication;
+ (UploadData *)sharedUploadData;
+ (State *)sharedState;
+ (UtilExtension *)sharedUtilExtension;
- (void)resetViews;
@end

