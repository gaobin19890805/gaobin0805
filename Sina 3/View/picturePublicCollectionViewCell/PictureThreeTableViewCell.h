//
//  PictureThreeTableViewCell.h
//  Sina
//
//  Created by qianfeng on 15/6/4.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureThreeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *firstImgView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImgView;
@property (weak, nonatomic) IBOutlet UILabel *tittleLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@end
