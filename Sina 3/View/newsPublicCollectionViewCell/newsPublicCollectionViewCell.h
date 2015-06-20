//
//  newsPublicCollectionViewCell.h
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
@interface newsPublicCollectionViewCell : UICollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame;
-(void)showCollectionViewCell:(NSIndexPath *)indexpath andSwitchIsOn:(NSString *)sw ;
-(void) requestURl:(NSIndexPath *)indexPath andPage:(NSInteger)page;

@end
