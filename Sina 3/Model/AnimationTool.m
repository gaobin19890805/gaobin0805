//
//  AnimationTool.m
//  homework11
//
//  Created by qianfeng on 15-4-21.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "AnimationTool.h"

@implementation AnimationTool
+(CATransition *)animationIn
{
    CATransition *animation=[CATransition animation];
    [animation setType:@"moveIn"];
    [animation setSubtype:kCATransitionFromBottom];
    animation.duration=0.5f;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return animation;
}
+(CATransition *)animationOut
{
    CATransition *animation=[CATransition animation];
    [animation setType:@"reveal"];
    [animation setSubtype:kCATransitionFromTop];
    animation.duration=0.5f;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return animation;
}
@end
