//
//  newsPublicImageTableViewCell.h
//  Sina
//
//  Created by qianfeng on 15/6/2.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newsPublicImageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *imgTittleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstImgView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImgView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImgView;
@property (weak, nonatomic) IBOutlet UILabel *conmentTotalLabel;

@end
