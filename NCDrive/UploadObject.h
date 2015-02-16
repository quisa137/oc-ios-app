//
//  UploadObject.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 9. 3..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "oc-ios-lib/OCCommunicationLib/OCCommunicationLib/OCFileDto.h"

@interface UploadObject : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSNumber *date;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;

@end

@interface UploadData : NSObject

@property (nonatomic,strong) NSMutableArray *current;
@property (nonatomic,strong) NSMutableArray *failed;
@property (nonatomic,strong) NSMutableArray *uploader;
@property (atomic) NSInteger reloadCnt;
@property (atomic,strong) NSLock *mylock;

-(void) loadData;
-(void) saveData;
-(void)addReloadCnt:(NSInteger)i;
-(NSInteger)getReloadCnt;

@end
