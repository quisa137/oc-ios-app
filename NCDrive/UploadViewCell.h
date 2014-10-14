//
//  UploadViewCell.h
//  NCDrive
//
//  Created by JangJaeMan on 2014. 9. 3..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadViewCell : UITableViewCell {
    UILabel *name;
    UILabel *prop;
    UIImageView *image;
    UIImageView *cacheImage;
    UIImageView *shareImage;
    UIImageView *favoriteImage;
    UIProgressView *progress;
}

@property (nonatomic,retain) IBOutlet UILabel *name;
@property (nonatomic,retain) IBOutlet UILabel *prop;
@property (nonatomic,retain) IBOutlet UIImageView *image;
@property (nonatomic,retain) IBOutlet UIImageView *cacheImage;
@property (nonatomic,retain) IBOutlet UIImageView *shareImage;
@property (nonatomic,retain) IBOutlet UIImageView *favoriteImage;
@property (nonatomic,retain) IBOutlet UIProgressView *progress;


@end
