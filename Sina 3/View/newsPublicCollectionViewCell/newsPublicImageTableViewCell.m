//
//  newsPublicImageTableViewCell.m
//  Sina
//
//  Created by qianfeng on 15/6/2.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "newsPublicImageTableViewCell.h"

@implementation newsPublicImageTableViewCell
-(void)awakeFromNib
{
    self.firstImgView.layer.borderWidth=0.4;
    self.firstImgView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.secondImgView.layer.borderWidth=0.4;
    self.secondImgView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.thirdImgView.layer.borderWidth=0.4;
    self.thirdImgView.layer.borderColor=[UIColor whiteColor].CGColor;
}
@end
