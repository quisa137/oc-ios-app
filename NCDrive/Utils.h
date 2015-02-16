//
//  Utils.h
//  OCLibraryExample
//
//  Created by JangJaeMan on 2014. 7. 31..
//  Copyright (c) 2014년 ownCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UploadObject.h"

static NSString *PathPrefix = @"remote.php/webdav/";

typedef enum _UtilFileType {
    kFileTypeNone = 0,
    kFileTypeImage,
    kFileTypePdf,
    kFileTypeText,
    kFileTypeAudio,
    kFileTypeMPEG4,
    kFileTypeOffice,
    kFileTypeOtherVideo
} UtilFileType;

#define IS_IPHONE5_OR_LATER (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IPAD             (([[[UIDevice currentDevice] model] hasPrefix:@"iPad"])?YES:NO)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface UtilExtension : NSObject
@property NSArray *list_epub;
@property NSArray *list_javascript;
@property NSArray *list_pdf;
@property NSArray *list_rss;
@property NSArray *list_cbr;
@property NSArray *list_flash;
@property NSArray *list_audio;
@property NSArray *list_database;
@property NSArray *list_font;
@property NSArray *list_svg;
@property NSArray *list_image;
@property NSArray *list_package;
@property NSArray *list_calendar;
@property NSArray *list_code;
@property NSArray *list_code_c;
@property NSArray *list_header;
@property NSArray *list_html;
@property NSArray *list_vcard;
@property NSArray *list_python;
@property NSArray *list_text;
@property NSArray *list_video;
@property NSArray *list_web;
@property NSArray *list_office_document;
@property NSArray *list_office_presentation;
@property NSArray *list_office_spreadsheet;

-(NSString *) getIconName:(NSString *)path;
-(UtilFileType) getFileType:(NSString *)path;
@end

@interface Utils : NSObject
// Documents 내의 Cache Directory를 경로를 가져온다.
+(NSString *) getCacheDir;
+(NSString *) getCacheDirWithPath:(NSString *)path;
+(NSString *) getCacheFileWithPath:(NSString *)path withFileName:(NSString *)filename;

// Temp 경로정보
+(NSString *) getTempFile;
+(NSString *) getTempFileWithFileName:(NSString *)filename;

// File URL
+(NSString *) getFileURLwithPath:(NSString *)path withFileName:(NSString *)filename;
+(NSString *) getHomeURL;
+(NSString *) getHomeURLwithPath:(NSString *)path;

// CacheManage
+(BOOL) clearAllCache;
+(BOOL) clearOldData;
+(BOOL) clearOldDataWithPath:(NSString *)path withRecursive:(BOOL)recursive;

// PList Config Read
+(NSString *)getPlistConfigForKey:(NSString *)key;

// ETC
+(UtilFileType) getFileType:(NSString *)filepath;
+(NSString *) humanReadableSize:(NSInteger)value;
+(NSString*) timeAgoString:(NSInteger)value;
+(void) showAlert:(NSString *)title withMsg:(NSString *)msg;

#pragma mark - UserDefaults
+(NSString *) getConfigForKey:(NSString *)key;
+(void) setConfigForKey:(NSString *)key withValue:(NSString *)value withSync:(BOOL)sync;
+(NSString *)currentVersion;
+(NSString *)currentBuildVersion;
+(NSString *)currentRemoteVersion;
+(NSInteger)versionCompare:(NSString *)versionString;

@end
