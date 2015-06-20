//
//  newsPublicTableViewCell.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "newsPublicTableViewCell.h"

@implementation newsPublicTableViewCell
-(void)awakeFromNib
{
    self.imgView.layer.borderWidth=0.4;
    self.imgView.layer.borderColor=[UIColor whiteColor].CGColor;
}
@end
