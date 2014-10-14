//
//  ChooseFolderCellTableViewCell.m
//  NCDrive
//
//  Created by JangJaeMan on 2014. 8. 28..
//  Copyright (c) 2014년 JangJaeMan. All rights reserved.
//

#import "ChooseFolderCell.h"

@implementation ChooseFolderCell

@synthesize _myImageView,_myTextLabel;

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
    self._myImageView.frame = frame;
    
    self._myTextLabel.font = [UIFont systemFontOfSize:14];
     */
}

@end
