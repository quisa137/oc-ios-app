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

@synthesize favContext;
@synthesize favObjModel;
@synthesize favPsc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(deleteCache:) userInfo:nil repeats:YES];
    [timer fire];
    
    return YES;
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)favContext
{
    if (_favContext != nil) {
        return _favContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self favPsc];
    if (coordinator != nil) {
        _favContext = [[NSManagedObjectContext alloc] init];
        [_favContext setPersistentStoreCoordinator:coordinator];
    }
    return _favContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)favObjModel
{
    if (_favObjModel != nil) {
        return _favObjModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Favorite" withExtension:@"momd"];
    _favObjModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _favObjModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)favPsc
{
    if (_favPsc != nil) {
        return _favPsc;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DBUCoreData.sqlite"];
    
    NSError *error = nil;
    _favPsc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self favObjModel]];
    if (![_favPsc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _favPsc;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjContext = self.favContext;
    if (managedObjContext != nil) {
        if ([managedObjContext hasChanges] && ![managedObjContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
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
