//
//  Favorite.h
//  NCDrive
//
//  Created by 박신구 on 2014. 10. 15..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FavoriteDocument : NSObject {
    NSManagedObjectContext *_favContext;
    NSManagedObjectModel *_favModel;
    NSPersistentStoreCoordinator *_persistStoreCoordinator;
}
@property (nonatomic, retain, readonly) NSManagedObjectModel *favModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *favContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
-(NSURL *)applicationDocumentDirectory;
@end
