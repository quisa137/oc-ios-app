//
//  FilesViewCell.h
//
//  Created by JangJaeMan on 2014. 7. 31..
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface FilesViewCell : SWTableViewCell {
    UILabel *name;
    UILabel *prop;
    UIImageView *image;
    UIImageView *cacheImage;
    UIImageView *shareImage;
    UIImageView *favoriteImage;
}

@property (nonatomic,retain) IBOutlet UILabel *name;
@property (nonatomic,retain) IBOutlet UILabel *prop;
@property (nonatomic,retain) IBOutlet UIImageView *image;
@property (nonatomic,retain) IBOutlet UIImageView *cacheImage;
@property (nonatomic,retain) IBOutlet UIImageView *shareImage;
@property (nonatomic,retain) IBOutlet UIImageView *favoriteImage;

@end
