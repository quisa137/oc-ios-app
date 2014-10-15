//
//  AppDelegate.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 12..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(deleteCache:) userInfo:nil repeats:YES];
    [timer fire];
    
    _favDocument = [[FavoriteDocument alloc] init];
    self.favContext = _favDocument.favContext;
    
    return YES;
}

- (IBAction)deleteCache:(id)sender
{
    [Utils clearOldData];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - OCCommunication Singleton
#pragma mark - OCCommunications

+ (OCCommunication*)sharedOCCommunication
{
    static OCCommunication* sharedOCCommunication = nil;
    if (sharedOCCommunication == nil)
    {
        sharedOCCommunication = [[OCCommunication alloc] init];
    }
    return sharedOCCommunication;
}

+ (UploadData *) sharedUploadData
{
    static UploadData *sharedUploadData = nil;
    if(sharedUploadData == nil)
    {
        sharedUploadData = [[UploadData alloc] init];
        [sharedUploadData loadData];
    }
    return sharedUploadData;
}

+ (State *) sharedState
{
    static State *sharedState = nil;
    if(sharedState == nil)
    {
        sharedState = [[State alloc] init];
    }
    return sharedState;
}

+ (UtilExtension *) sharedUtilExtension
{
    static UtilExtension *sharedUtilExtension = nil;
    if(sharedUtilExtension == nil)
    {
        sharedUtilExtension = [[UtilExtension alloc] init];
    }
    return sharedUtilExtension;
}

+ (NSManagedObjectContext *) sharedFav {
    static NSManagedObjectContext *sharedFav = nil;
    if(sharedFav == nil) {
        sharedFav = [[NSManagedObjectContext alloc] init];
    }
    return sharedFav;
}

- (void)resetViews {
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    [tabBarController setSelectedIndex:0];

    UINavigationController *navCtrl = (UINavigationController *)self.window.rootViewController.navigationController;
    for(UINavigationController *nc in navCtrl.viewControllers) {
        [nc popToRootViewControllerAnimated:YES];
    }
}
@end
