//
//  UploadObject.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 9. 3..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "UploadObject.h"

@implementation UploadObject

@synthesize progress,fileName,filePath,size,date,errMsg;

@end

@implementation UploadData

-(id) init
{
    self = [super init];
    if(self){
        self.reloadCnt = 0;
        self.mylock = [[NSLock alloc] init];
    }
    return self;
}

-(void)addReloadCnt:(NSInteger)i
{
    [self.mylock lock];
    self.reloadCnt = self.reloadCnt + i;
    [self.mylock unlock];
}

-(NSInteger)getReloadCnt
{
    NSInteger ret;
    [self.mylock lock];
    ret = self.reloadCnt;
    [self.mylock unlock];
    return ret;
}

-(void) loadData
{
    //
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.current  = [[NSMutableArray alloc] init];
    
    // Failed Data
    self.failed  = [[NSMutableArray alloc] init];
    NSArray *t_failed = [defaults objectForKey:@"upload_faild"];
    for(NSDictionary *t_data in t_failed){
        UploadObject *t_obj = [[UploadObject alloc] init ];
        
        t_obj.fileName = [t_data objectForKey:@"fileName"];
        t_obj.filePath = [t_data objectForKey:@"filePath"];
        t_obj.errMsg = [t_data objectForKey:@"errMsg"];
        t_obj.date = [t_data objectForKey:@"date"];
        t_obj.size = [t_data objectForKey:@"size"];
        
        [self.failed addObject:t_obj];
    }
    
    // UPloader Data
    self.uploader  = [[NSMutableArray alloc] init];
    NSArray *t_uploader = [defaults objectForKey:@"upload_uploader"];
    for(NSDictionary *t_data in t_uploader){
        UploadObject *t_obj = [[UploadObject alloc] init ];
        
        t_obj.fileName = [t_data objectForKey:@"fileName"];
        t_obj.filePath = [t_data objectForKey:@"filePath"];
        t_obj.errMsg = [t_data objectForKey:@"errMsg"];
        t_obj.date = [t_data objectForKey:@"date"];
        t_obj.size = [t_data objectForKey:@"size"];
        
        [self.uploader addObject:t_obj];
    }
}

-(void) saveData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Failed
    NSMutableArray *t_array = [[NSMutableArray alloc] init];
    for(UploadObject *t_obj in self.failed){
        NSDictionary *t_dic = [[NSDictionary alloc] init];
        
        [t_dic setValue:t_obj.fileName forKey:@"fileName"];
        [t_dic setValue:t_obj.filePath forKey:@"filePath"];
        [t_dic setValue:t_obj.date forKey:@"date"];
        [t_dic setValue:t_obj.size forKey:@"size"];
        
        [t_array addObject:t_dic];
    }
    [defaults setValue:t_array forKey:@"upload_failed"];
    
    
     // Failed
    t_array = [[NSMutableArray alloc] init];
    for(UploadObject *t_obj in self.uploader){
        NSDictionary *t_dic = [[NSDictionary alloc] init];
        
        [t_dic setValue:t_obj.fileName forKey:@"fileName"];
        [t_dic setValue:t_obj.filePath forKey:@"filePath"];
        [t_dic setValue:t_obj.date forKey:@"date"];
        [t_dic setValue:t_obj.size forKey:@"size"];
        
        [t_array addObject:t_dic];
    }
    [defaults setValue:t_array forKey:@"upload_uploader"];
}

@end
