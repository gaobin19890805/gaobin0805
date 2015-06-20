//
//  PictureViewController.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "PictureViewController.h"
#import "picturePublicCollectionViewCell.h"
#import "DetailsViewController.h"
@implementation PictureViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tittleArr = [NSMutableArray arrayWithObjects:@"精选",@"奇趣",@"美女",@"故事" ,nil];
     [_collectionView registerClass:[picturePublicCollectionViewCell class] forCellWithReuseIdentifier:@"a"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pictureRespose:) name:@"Picture" object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Picture" object:nil];
}
-(void)pictureRespose:(NSNotification *)n
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
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tittleArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    picturePublicCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"a" forIndexPath:indexPath];
    [cell showCollectionViewCell:indexPath];
    
    return cell;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.tabBarController.tabBar.hidden=NO;
    _titleView.hidden=NO;
}
@end
