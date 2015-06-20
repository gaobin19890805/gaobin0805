//
//  NewsViewController.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "NewsViewController.h"
#import "newsPublicCollectionViewCell.h"
#import "AFNetworking.h"
#import "DetailsViewController.h"
@implementation NewsViewController
-(void)viewDidLoad
{
    //必须加载父类的方法
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent=YES;
    _statusSwitchIsOn=@"1";
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.tittleArr=[NSMutableArray arrayWithObjects:@"头条",@"娱乐",@"体育",@"财经",@"科技",@"搞笑",@"汽车",nil];
    [_collectionView registerClass:[newsPublicCollectionViewCell class] forCellWithReuseIdentifier:@"abc"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newsRespose:) name:@"id" object:nil];
   
    [NSThread sleepForTimeInterval:3];
    //添加消息通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(responseStatus:) name:@"SwitchIsOn" object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SwitchIsOn" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"id" object:nil];
}
-(void)responseStatus:(NSNotification *)n
{
    _statusSwitchIsOn=(NSString *)[n object];
   // NSLog(@"%@",_statusSwitchIsOn);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    newsPublicCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"abc" forIndexPath:indexPath];
    [cell showCollectionViewCell:indexPath andSwitchIsOn:_statusSwitchIsOn];
    return cell;
}
//监听到消息推送界面
-(void)newsRespose:(NSNotification *)n
{
    NSArray *arr=(NSArray *)[n object];
    DetailsViewController *detailController=[[DetailsViewController alloc]init];
    detailController.url=[arr objectAtIndex:0];
    detailController.tittleStr=[arr objectAtIndex:1];
    _titleView.hidden=YES;
    //隐藏 tabbar
    self.navigationController.tabBarController.tabBar.hidden=YES;
    [self.navigationController pushViewController:detailController animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _titleView.hidden=NO;
    self.navigationController.tabBarController.tabBar.hidden=NO;
    //self.tabBarController.tabBar.hidden=NO;
}
@end
