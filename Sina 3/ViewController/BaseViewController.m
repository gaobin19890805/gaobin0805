//
//  BaseViewController.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "BaseViewController.h"
#import "AFNetworking.h"
@interface BaseViewController (){
    UILabel *_lastLabel;
}
@end
@implementation BaseViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    //self.navigationController.navigationBar.translucent=NO;
    _titleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width -70, self.navigationController.navigationBar.frame.size.height)];
    _titleView.contentSize=CGSizeMake(20, 0);
    _titleView.showsHorizontalScrollIndicator=NO;
    _lineView=[[UIView alloc]init];
    _lineView.backgroundColor=[UIColor orangeColor];
    //_titleView.backgroundColor=[UIColor yellowColor];
    [self.navigationController.navigationBar addSubview:_titleView];
    
    
    
    UICollectionViewFlowLayout*layout=[[UICollectionViewFlowLayout alloc]init];
    //设置滚动方向为水平
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    //设置行间距为零
    layout.minimumLineSpacing=0;
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49) collectionViewLayout:layout];
    _collectionView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    //设置为可翻页
    _collectionView.pagingEnabled=YES;
    _collectionView.showsHorizontalScrollIndicator=NO;
    //给标题做监听
    [self addObserver:self forKeyPath:@"tittleArr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    //添加消息通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(responseStatus:) name:@"SwitchIsOn" object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SwitchIsOn" object:nil];
    [self removeObserver:self forKeyPath:@"tittleArr"];
}
-(void)responseStatus:(NSNotification *)n
{
    _statusSwitchIsOn=(NSString *)[n object];
    //打印
    NSLog(@"%@",_statusSwitchIsOn);
}
//当值变化时
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setUpTittleScrollView];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tittleArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:(arc4random() % 255) / 255.0 green:(arc4random() % 255) / 255.0 blue:(arc4random() % 255) / 255.0 alpha:1];
    //cell.backgroundColor=[UIColor redColor];
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49);
}
-(void)setUpTittleScrollView
{
    for (int i=0; i<_tittleArr.count; i++) {
        UILabel *label=[[UILabel alloc]init];
        label.tag=100+i;
        UIFont *font=[UIFont fontWithName:@"HelveticaNeue" size:14];
        label.font=font;
        NSString *str=_tittleArr[i];
        CGSize size=[str sizeWithAttributes:@{NSFontAttributeName:font}];
        //给 label 添加点击手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        label.userInteractionEnabled=YES;
        [label addGestureRecognizer:tap];
        if (i==0) {
            label.frame=CGRectMake(20, 0, size.width, self.navigationController.navigationBar.frame.size.height);
            label.textColor=[UIColor orangeColor];
            _lineView.frame=CGRectMake(label.frame.origin.x, self.navigationController.navigationBar.frame.size.height-2, size.width, 2);
            _lastLabel=label;
        }
        else{
            UILabel *la=(UILabel *)[_titleView viewWithTag:label.tag-1];
            label.frame=CGRectMake(la.frame.origin.x+la.frame.size.width+20, 0, size.width, self.navigationController.navigationBar.frame.size.height);
        }
        CGSize contentSize=_titleView.contentSize;
        contentSize.width+=size.width+20;
        _titleView.contentSize=contentSize;
        label.text=_tittleArr[i];
        [_titleView addSubview:label];
        [_titleView addSubview:_lineView];
    }
}
-(void)tapClick:(UITapGestureRecognizer *)tap
{
    _lastLabel.textColor=[UIColor blackColor];
    UILabel *label=(UILabel *)tap.view;
    NSLog(@"%li",label.tag);
    label.textColor=[UIColor orangeColor];
    _lastLabel=label;
    _lineView.frame=CGRectMake(label.frame.origin.x, self.navigationController.navigationBar.frame.size.height-2, label.frame.size.width, 2);
    _collectionView.contentOffset=CGPointMake((tap.view.tag-100)*[UIScreen mainScreen].bounds.size.width, 0);
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //上次点击的Label 变回黑色
    _lastLabel.textColor=[UIColor blackColor];
    int count=(int)_collectionView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    UILabel *lable=(UILabel *)[self.navigationController.navigationBar viewWithTag:100+count];
    lable.textColor=[UIColor orangeColor];
    _lastLabel=lable;
    UIFont *fout=[UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize size=CGSizeMake(20,  self.navigationController.navigationBar.frame.size.height-2);
    for (int i=0; i<count; i++) {
        size.width+=[self.tittleArr[i] sizeWithAttributes:@{NSFontAttributeName:fout}].width+20;
    }
    _lineView.frame=CGRectMake(size.width, size.height,[self.tittleArr[count] sizeWithAttributes:@{NSFontAttributeName:fout}].width, 2);
       if (size.width>_titleView.frame.size.width) {
           _titleView.contentOffset=CGPointMake(150, 0);
        }
        else
        {
            _titleView.contentOffset=CGPointZero;
        }
   }

@end
