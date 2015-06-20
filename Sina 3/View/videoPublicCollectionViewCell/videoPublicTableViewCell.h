//
//  videoPublicTableViewCell.h
//  Sina
//
//  Created by qianfeng on 15/6/2.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface videoPublicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *tittleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *runTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *blackView;
@end
