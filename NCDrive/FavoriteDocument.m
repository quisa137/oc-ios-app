//
//  Favorite.m
//  NCDrive
//
//  Created by 박신구 on 2014. 10. 15..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "FavoriteDocument.h"

@implementation FavoriteDocument
@synthesize favContext = _favContext;
@synthesize favModel = _favModel;
@synthesize persistentStoreCoordinator = _persistStoreCoordinator;

-(void)dealloc{
    _favModel = nil;
    _favContext = nil;
    _persistStoreCoordinator = nil;
}


#pragma mark -
#pragma mark MyManagedDocument
-(void)saveContext {
    NSError *error;
    NSManagedObjectContext *favContext = self.favContext;
    
    if (favContext != nil) {
        // 변경 사항이 있지만 저장에 실패한 경우
        if ([favContext hasChanges] && ![favContext save:&error]) {
            NSLog(@"Unresolved error : %@, %@", error, [error userInfo]);
        }
    }
}

-(NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask]
            lastObject];
}


#pragma mark -
#pragma mark FavoriteDocument [@property]
-(NSManagedObjectModel *)favModel {
    if (_favModel != nil)
        return _favModel;
    
    // 컴파일된 Data Object Model(Xcode상의 .xcdatamodeld)에 접근하여 객체로 생성.
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Favorite" withExtension:@"momd"];
    _favModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _favModel;
}

-(NSManagedObjectContext *)favContext {
    if (_favContext != nil)
        return _favContext;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil){
        _favContext = [[NSManagedObjectContext alloc] init];
        
        // Persistent Store Coordinator 연결.
        [_favContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _favContext;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistStoreCoordinator != nil)
        return _persistStoreCoordinator;
    
    _persistStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self favModel]];
    
    NSError *error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Favorite.sqlite"];
    
    // Persistent Store Coordinator 설정. 저장소 타입을 SQLite로 한다.
    if (![_persistStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        NSLog(@"Unresolved error : %@, %@", error, [error userInfo]);
    }
    
    return _persistStoreCoordinator;
}

@end