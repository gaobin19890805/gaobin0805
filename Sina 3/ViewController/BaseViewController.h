//
//  BaseViewController.h
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

{
    //导航栏标题滚动视图
    UIScrollView * _titleView;
    //标题下划线
    UIView *_lineView;
    UICollectionView *_collectionView;
    
    NSString  *_statusSwitchIsOn;
}
@property(strong,nonatomic)NSMutableArray *tittleArr;
@end
