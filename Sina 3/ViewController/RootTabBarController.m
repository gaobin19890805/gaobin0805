//
//  RootTabBarController.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "RootTabBarController.h"
#import "NewsViewController.h"
#import "PictureViewController.h"
#import "VideoViewController.h"
#import "MineViewController.h"
#import "MyNavigationController.h"
@implementation RootTabBarController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.translucent=NO;
    NewsViewController *newsController=[[NewsViewController alloc]init];
    //添加消息中心
    //[[NSNotificationCenter defaultCenter]addObserver:newsController selector:@selector(newsRespose:) name:@"news" object:nil];
    [self setupChildViewContoller:newsController andTittle:@"新闻" andImage:[UIImage imageNamed:@"tabbar_news@3x.png"] andSelectedImage: [[UIImage imageNamed:@"tabbar_news_hl@3x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    PictureViewController *pictureController=[[PictureViewController alloc]init];
    //pictureController.view.backgroundColor=[UIColor cyanColor];
    [self setupChildViewContoller:pictureController andTittle:@"图片" andImage:[UIImage imageNamed:@"tabbar_picture@3x.png"] andSelectedImage: [[UIImage imageNamed:@"tabbar_picture_hl@3x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    VideoViewController *videoController=[[VideoViewController alloc]init];
    //videoController.view.backgroundColor=[UIColor orangeColor];
   [self setupChildViewContoller:videoController andTittle:@"视频" andImage:[UIImage imageNamed:@"tabbar_video@3x.png"] andSelectedImage: [[UIImage imageNamed:@"tabbar_video_hl@3x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    MineViewController *mineController=[[MineViewController alloc]init];
    //mineController.view.backgroundColor=[UIColor yellowColor];
    [self setupChildViewContoller:mineController andTittle:@"我的" andImage:[UIImage imageNamed:@"tabbar_setting@3x.png"] andSelectedImage: [[UIImage imageNamed:@"tabbar_setting_hl@3x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
}
-(void)setupChildViewContoller:(UIViewController *)childVC andTittle:(NSString *)tittle andImage:(UIImage *)image andSelectedImage:(UIImage *)selectedImage
{
    childVC.tabBarItem.title=tittle;
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} forState:UIControlStateSelected];
    childVC.tabBarItem.image=image;
    childVC.tabBarItem.selectedImage=selectedImage;
    if ([tittle isEqualToString:@"我的"]) {
         MyNavigationController *nav=[[MyNavigationController alloc]initWithRootViewController:childVC];
        [self addChildViewController:nav];
    }
    else
    {
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:childVC];
        [self addChildViewController:nav];
    }
    
    
}

@end

