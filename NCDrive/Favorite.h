//
//  Favorite.h
//  NCDrive
//
//  Created by 박신구 on 2014. 10. 15..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * fileUrl;
@property (nonatomic, retain) NSString * uid;

@end
