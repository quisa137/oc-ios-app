//
//  Utils.m
//  OCLibraryExample
//
//  Created by JangJaeMan on 2014. 7. 31..
//  Copyright (c) 2014년 ownCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"



@implementation UtilExtension

-(id) init
{
    self = [super init];
    if(self){
        self.list_epub           = @[@"epub"];
        self.list_javascript     = @[@"js"];
        self.list_pdf            = @[@"pdf"];
        self.list_rss            = @[@"rss"];
        self.list_cbr            = @[@"cbr"];
        self.list_flash          = @[@"fla",@"flv",@"swf"];
        self.list_audio          = @[@"mp3",@"ac3",@"wav",@"aiff",@"ogg",@"flac",@"aac",@"au",@"rm"];
        self.list_database       = @[@"db"];
        self.list_font           = @[@"otf",@"ttf",@"ttc"];
        self.list_svg            = @[@"svg",@"ai"];
        self.list_image          = @[@"jpg",@"jpeg",@"png",@"gif",@"psd"];
        self.list_package        = @[@"tar",@"zip",@"alz",@"7z",@"gz",@"gzip",@"rar"];
        self.list_calendar       = @[@"calendar"];
        self.list_code           = @[@"m",@"ruby",@"perl",@"php",@"java"];
        self.list_code_c         = @[@"c",@"cc",@"c++",@"cxx",@"cpp"];
        self.list_header         = @[@"h",@"hh",@"hpp"];
        self.list_html           = @[@"html",@"xhtml",@"xml"];
        self.list_vcard          = @[@"vcard"];
        self.list_python         = @[@"py",@"pyc"];
        self.list_text           = @[@"txt",@"text",@"log"];
        self.list_video          = @[@"mp4",@"avi",@"mkv",@"wmv",@"asf",@"webm",@"mov",@"rm"];
        self.list_web            = @[@"url"];
        self.list_office_document= @[@"doc",@"docx",@"hwp",@"odt",@"rtf"];
        self.list_office_presentation = @[@"ppt",@"pptx",@"odp"];
        self.list_office_spreadsheet = @[@"xls",@"xlsx",@"odc"];

    }    
    return self;
}

-(BOOL) isExist:(NSString *)ext withArray:(NSArray *)arr
{
    for(NSString *item in arr){
        if([item isEqualToString:ext]){
            return YES;
        }
    }
    return NO;
}

-(NSString *) getIconName:(NSString *)path
{
    NSString *ext = [[path pathExtension] lowercaseString];
    NSString *prefix = nil;
    
    if([self isExist:ext withArray:self.list_epub]){
        prefix = @"application-epub+zip";
    }else if([self isExist:ext withArray:self.list_javascript]){
        prefix = @"application-javascript";
    }else if([self isExist:ext withArray:self.list_pdf]){
        prefix = @"application-pdf";
    }else if([self isExist:ext withArray:self.list_rss]){
        prefix = @"application-rss+xml";
    }else if([self isExist:ext withArray:self.list_cbr]){
        prefix = @"application-x-cbr";
    }else if([self isExist:ext withArray:self.list_flash]){
        prefix = @"application-x-shockwave-flash";
    }else if([self isExist:ext withArray:self.list_audio]){
        prefix = @"audio";
    }else if([self isExist:ext withArray:self.list_database]){
        prefix = @"database";
    }else if([self isExist:ext withArray:self.list_font]){
        prefix = @"font";
    }else if([self isExist:ext withArray:self.list_svg]){
        prefix = @"image-svg+xml";
    }else if([self isExist:ext withArray:self.list_image]){
        prefix = @"image";
    }else if([self isExist:ext withArray:self.list_package]){
        prefix = @"package-x-generic";
    }else if([self isExist:ext withArray:self.list_calendar]){
        prefix = @"text-calendar";
    }else if([self isExist:ext withArray:self.list_code]){
        prefix = @"text-code";
    }else if([self isExist:ext withArray:self.list_code_c]){
        prefix = @"text-x-c";
    }else if([self isExist:ext withArray:self.list_header]){
        prefix = @"text-x-h";
    }else if([self isExist:ext withArray:self.list_html]){
        prefix = @"text-html";
    }else if([self isExist:ext withArray:self.list_vcard]){
        prefix = @"text-vcard";
    }else if([self isExist:ext withArray:self.list_python]){
        prefix = @"text-x-python";
    }else if([self isExist:ext withArray:self.list_text]){
        prefix = @"text";
    }else if([self isExist:ext withArray:self.list_video]){
        prefix = @"video";
    }else if([self isExist:ext withArray:self.list_web]){
        prefix = @"web";
    }else if([self isExist:ext withArray:self.list_office_document]){
        prefix = @"x-office-document";
    }else if([self isExist:ext withArray:self.list_office_presentation]){
        prefix = @"x-office-presentation";
    }else if([self isExist:ext withArray:self.list_office_spreadsheet]){
        prefix = @"x-office-spreadsheet";
    }else{
        prefix = @"file";
    }
    
    return [[NSString alloc] initWithFormat:@"%@.png",prefix];
}

-(UtilFileType) getFileType:(NSString *)path
{
    NSString *ext = [[path pathExtension] lowercaseString];
    
    //
    if(
        [self isExist:ext withArray:self.list_javascript]
        || [self isExist:ext withArray:self.list_rss]
        || [self isExist:ext withArray:self.list_code]
        || [self isExist:ext withArray:self.list_code_c]
        || [self isExist:ext withArray:self.list_header]
        || [self isExist:ext withArray:self.list_html]
        || [self isExist:ext withArray:self.list_text]
        || [self isExist:ext withArray:self.list_python]
        || [self isExist:ext withArray:self.list_web]
    ){
        return kFileTypeText;
    }
    
    if(
        [self isExist:ext withArray:self.list_pdf]
    ){
        return kFileTypePdf;
    }
    
    if(
        [self isExist:ext withArray:self.list_audio]
    ){
        return kFileTypeAudio;
    }
    
    if(
        [self isExist:ext withArray:self.list_video]
    ){
        if([ext isEqualToString:@"mp4"]){
            return kFileTypeMPEG4;
        }else{
            return kFileTypeOtherVideo;
        }
    }
    
    if(
        [self isExist:ext withArray:self.list_image]
    ){
        return kFileTypeImage;
    }
    
    if(
        [self isExist:ext withArray:self.list_office_document]
        || [self isExist:ext withArray:self.list_office_presentation]
        || [self isExist:ext withArray:self.list_office_spreadsheet]
    ){
        return kFileTypeOffice;
    }

    return kFileTypeNone;
}

@end

@implementation Utils

#pragma mark Cache Path
+(NSString *) getCacheDir
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:[Utils getConfigForKey:@"host"]];
    NSString *host = [url host];
    NSString *userid = [Utils getConfigForKey:@"userid"];
    
    return [[NSString alloc] initWithFormat:@"%@/%@/%@",documentsDirectory,host,userid];
}

+(NSString *)getCacheDirWithPath:(NSString *)path
{
    return [[Utils getCacheDir] stringByAppendingPathComponent:[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+(NSString *)getCacheFileWithPath:(NSString *)path withFileName:(NSString *)filename
{
    NSString *cachefile = [[Utils getCacheDirWithPath:path] stringByAppendingPathComponent:[filename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return cachefile;
}

#pragma mark TempPath
+(NSString *)getTempFile
{
    NSString *fileName = [NSString stringWithFormat:@"%@", [[NSProcessInfo processInfo] globallyUniqueString]];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

+(NSString *)getTempFileWithFileName:(NSString *)filename
{
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString],[filename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

#pragma mark Make URL
+(NSString *) getFileURLwithPath:(NSString *)path withFileName:(NSString *)filename
{
    NSString *host = [Utils getConfigForKey:@"host"];
    return [[NSString alloc] initWithFormat:@"%@/%@/%@",host,[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[filename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+(NSString *) getHomeURL
{
    NSString *host = [Utils getConfigForKey:@"host"];
    return [[NSString alloc] initWithFormat:@"%@/%@",host,[PathPrefix stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+(NSString *) getHomeURLwithPath:(NSString *)path
{
    NSString *host = [Utils getConfigForKey:@"host"];
    return [[NSString alloc] initWithFormat:@"%@/%@",host,[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark CacheManage
+(BOOL) clearAllCache{
	NSString *cacheDir = [Utils getCacheDir];
	return [[NSFileManager defaultManager] removeItemAtPath:cacheDir error:nil];
}

+(BOOL) clearOldData{
    NSString *cacheDir = [Utils getCacheDir];
    return [Utils clearOldDataWithPath:cacheDir withRecursive:YES];
}

+(BOOL) clearOldDataWithPath:(NSString *)path withRecursive:(BOOL)recursive{
	NSString* file;
	NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [enumerator nextObject])
	{
		// check if it's a directory
		BOOL isDirectory = NO;
		NSString *fullpath = [NSString stringWithFormat:@"%@/%@",path,file];
		[[NSFileManager defaultManager] fileExistsAtPath:fullpath  isDirectory: &isDirectory];
		if (!isDirectory)
		{
			// Check  Create Date
			NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullpath error:nil];
			NSDate *creationDate = attributes[NSFileCreationDate];
			
			NSTimeInterval gap = [creationDate timeIntervalSinceNow];

            if(gap < -3600){
                // Delete
                [[NSFileManager defaultManager] removeItemAtPath:fullpath error:nil];
            }
		}
		else
		{
			if(recursive == YES){
				[Utils clearOldDataWithPath:fullpath withRecursive:recursive];
			}
		}
	}
	return YES;
}

#pragma mark PList Config
+(NSString *) getPlistConfigForKey:(NSString *)key
{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    
    return (NSString *)[config objectForKey:key];
}


#pragma mark ETC

+ (NSString *)getTempFilePath
{
    NSString *tempFilePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (;;) {
        NSString *baseName = [NSString stringWithFormat:@"tmp-%x.caf", arc4random()];
        tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:baseName];
        if (![fileManager fileExistsAtPath:tempFilePath])
            break;
    }
    return tempFilePath;
}

+ (NSString *) humanReadableSize:(NSInteger)value
{
    double convertedValue = value;
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB"];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, tokens[multiplyFactor]];
}

+ (NSString*)timeAgoString:(NSInteger)value
{
    double eventSecondsSince1970 = value;
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:eventSecondsSince1970];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    int unitFlags = NSYearCalendarUnit |
                    NSMonthCalendarUnit |
                    NSDayCalendarUnit |
                    NSHourCalendarUnit |
                    NSMinuteCalendarUnit |
                    NSSecondCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:eventDate toDate:[NSDate date] options:0];
    
    NSString *timeAgoString = [NSString string];
    if ([comps year] > 0) {
        timeAgoString =
        [NSString stringWithFormat:@"%li years ago", (long)[comps year]];
    }
    else if ([comps month] > 0) {
        timeAgoString =
        [NSString stringWithFormat:@"%li month ago", (long)[comps month]];
    }
    else if ([comps day] > 0) {
        timeAgoString =
        [NSString stringWithFormat:@"%li days ago", (long)[comps day]];
    }
    else if ([comps hour] > 0) {
        timeAgoString =
        [NSString stringWithFormat:@"%li hours ago", (long)[comps hour]];
    }
    else if ([comps minute] > 0) {
        timeAgoString =
        [NSString stringWithFormat:@"%li mins ago", (long)[comps minute]];
    }
    else if ([comps second] > 0) {
        timeAgoString =
        [NSString stringWithFormat:@"%li secs ago", (long)[comps second]];
    }
    return timeAgoString;
}

+(NSString *) getConfigForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:key];
}

+(void) setConfigForKey:(NSString *)key withValue:(NSString *)value withSync:(BOOL)sync
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    if(sync == YES){
        [defaults synchronize];
    }
}

+(void) showAlert:(NSString *)title withMsg:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
    [alertView show];
}
+(NSString *)currentVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+(NSString *)currentBuildVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}
+(NSString *)currentRemoteVersion{
    return @"1.0.2";
}
+(NSInteger)versionCompare{
    NSArray *v1a = [[Utils currentVersion] componentsSeparatedByString:@"."];
    NSArray *v2a = [[Utils currentRemoteVersion] componentsSeparatedByString:@"."];
    NSInteger pzNum = fabs([v1a count] - [v2a count]);
    
    if ([v1a count]<[v2a count]) {
        for (NSInteger i = 0; i < pzNum; i++) {
            v1a = [v1a arrayByAddingObject:0];
        }
    }else if([v1a count]>[v2a count]){
        for (NSInteger i = 0; i < pzNum; i++) {
            v2a = [v2a arrayByAddingObject:0];
        }
    }
    
    for (NSInteger i=0; i < [v2a count]; i++) {
        NSInteger v1i = [v1a[i] integerValue];
        NSInteger v2i = [v2a[i] integerValue];
        if (v1i == v2i) {
            continue;
        }else if(v1i < v2i){
            return -1;
        }else if(v1i > v2i){
            return 1;
        }
    }
    return 0;
}

@end
