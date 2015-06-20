//
//  addCityViewController.h
//  Sina
//
//  Created by qianfeng on 15/6/9.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^complention)(NSString *str);
@interface addCityViewController : UIViewController
@property (nonatomic,copy) complention bl;
-(void)backData:(complention)block;
@end
