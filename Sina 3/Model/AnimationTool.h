//
//  AnimationTool.h
//  homework11
//
//  Created by qianfeng on 15-4-21.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
@interface AnimationTool : NSObject
+(CATransition *)animationIn;
+(CATransition *)animationOut;
@end
