//
//  State.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 9. 5..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "State.h"

@implementation State

-(id) init
{
    self = [super init];
    if(self){
        self.mylock = [[NSLock alloc] init];
        self.statea = [NSMutableArray arrayWithObjects:
                      [NSNumber numberWithBool:NO]
                      ,[NSNumber numberWithBool:NO]
                      ,[NSNumber numberWithBool:NO]
                      ,[NSNumber numberWithBool:NO]
                      , nil];
    }
    return self;
}

-(BOOL) isDirty{
    for(NSNumber *data in self.statea){
        BOOL t_state = [data boolValue];
        
        if(t_state == YES){
            return YES;
        }
    }
    return NO;
}
-(BOOL) isDirtyWithType:(DirtyType)type
{
    return [[self.statea objectAtIndex:type] boolValue];
}
-(void) setDirtyWithType:(DirtyType)type
{
    [self.statea replaceObjectAtIndex:type withObject:[NSNumber numberWithBool:YES]];
}
     
-(void) clearDirty
{
    self.statea = [NSMutableArray arrayWithObjects:
              [NSNumber numberWithBool:NO]
              ,[NSNumber numberWithBool:NO]
              ,[NSNumber numberWithBool:NO]
              ,[NSNumber numberWithBool:NO]
              , nil];
}
-(void) clearDirtyWithType:(DirtyType)type
{
    [self.statea replaceObjectAtIndex:type withObject:[NSNumber numberWithBool:NO]];
}

@end
