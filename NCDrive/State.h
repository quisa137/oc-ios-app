//
//  State.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 9. 5..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface State : NSObject

typedef enum {
    kDTUnknown      = 0,
    kDTUser         = 1,
    kDTUpload       = 2,
    kDTDelete       = 3
} DirtyType;

@property (atomic,strong) NSLock *mylock;
@property (atomic,strong) NSMutableArray *statea;

-(BOOL) isDirty;
-(BOOL) isDirtyWithType:(DirtyType)type;
-(void) setDirtyWithType:(DirtyType)type;
-(void) clearDirty;
-(void) clearDirtyWithType:(DirtyType)type;

@end
