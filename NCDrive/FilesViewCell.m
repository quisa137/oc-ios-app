//
//  FilesViewCell.m
//
//  Created by JangJaeMan on 2014. 7. 31..
//

#import "FilesViewCell.h"

@implementation FilesViewCell

@synthesize name,image,prop,cacheImage,favoriteImage,shareImage;

/*
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        // Initialization code
        
        name = [[UILabel alloc]init];
        name.textAlignment = UITextAlignmentLeft;
        name.font = [UIFont systemFontOfSize:14];
        
        prop = [[UILabel alloc]init];
        prop.textAlignment = UITextAlignmentLeft;
        prop.font = [UIFont systemFontOfSize:9];
        prop.textColor = [UIColor grayColor];
        
        image = [[UIImageView alloc]init];
        cacheImage = [[UIImageView alloc]init];
        
        [self.contentView addSubview:name];
        [self.contentView addSubview:image];
        [self.contentView addSubview:prop];
        [self.contentView addSubview:cacheImage];
    }
    return self;
}
*/

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    /*
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame = CGRectMake(boundsX+5, 5, 40, 40);
    image.frame = frame;
    
    frame = CGRectMake(boundsX+50, 5, 10, 10);
    cacheImage.frame = frame;
    
    frame = CGRectMake(boundsX+65, 5, 230, 30);
    name.frame = frame;
    
    frame = CGRectMake(boundsX+65, 35, 230, 10);
    prop.frame = frame;
     */
}

@end
