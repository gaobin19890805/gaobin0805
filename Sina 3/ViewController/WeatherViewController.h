//
//  WeatherViewController.h
//  Sina
//
//  Created by qianfeng on 15/6/9.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *lunarLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property(strong,nonatomic)NSMutableArray *cityArr;
@end
