//
//  newsPublicTableViewCell.h
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newsPublicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end
