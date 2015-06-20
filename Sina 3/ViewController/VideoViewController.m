//
//  VideoViewController.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "VideoViewController.h"
#import "videoPublicCollectionViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
@interface VideoViewController ()

@end
@implementation VideoViewController
-(void)viewDidLoad
{
    //必须加载父类的方法
    [super viewDidLoad];
    
    self.tittleArr=[NSMutableArray arrayWithObjects:@"热点",@"咨询台",@"奇趣",@"军情室", nil];
    [_collectionView registerClass:[videoPublicCollectionViewCell class] forCellWithReuseIdentifier:@"abc"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tittleArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    videoPublicCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"abc" forIndexPath:indexPath];
    [cell showCollectionViewCell:indexPath];
    return cell;
}
  

@end
