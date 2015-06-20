//
//  PictureThreeTableViewCell.m
//  Sina
//
//  Created by qianfeng on 15/6/4.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "PictureThreeTableViewCell.h"

@implementation PictureThreeTableViewCell

- (void)awakeFromNib {
    self.firstImgView.layer.borderWidth=1;
    self.firstImgView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.secondImgView.layer.borderWidth=1;
    self.secondImgView.layer.borderColor=[UIColor whiteColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
