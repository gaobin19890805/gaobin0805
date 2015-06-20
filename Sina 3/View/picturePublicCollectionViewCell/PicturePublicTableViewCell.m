//
//  picturePublicTableViewCell.m
//  Sina
//
//  Created by qianfeng on 15/6/4.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "picturePublicTableViewCell.h"

@implementation PicturePublicTableViewCell

- (void)awakeFromNib {
    self.oneimgView.layer.borderWidth=1;
    self.oneimgView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.secondImgView.layer.borderWidth=1;
    self.secondImgView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.threeImgView.layer.borderWidth=1;
    self.threeImgView.layer.borderColor=[UIColor whiteColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
