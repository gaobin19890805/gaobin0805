//
//  DetailsViewController.m
//  Sina
//
//  Created by qianfeng on 15/6/6.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "DetailsViewController.h"
#import "UMSocial.h"
@interface DetailsViewController ()
{
    //感兴趣 收藏
    UILabel *_label;
    UIView *_view;
    UIImageView *_imgView;
    
    NSString *_sandBoxString;
    NSMutableArray *_plistArr;
    
    //搜藏点击次数
    int _clickCount;
}
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _plistArr=[NSMutableArray array];
    NSArray *arry=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _sandBoxString=[arry objectAtIndex:0];
    
    NSLog(@"%@",_sandBoxString);
    UIWebView *wbView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:wbView];
    NSURL *url=[NSURL URLWithString:self.url];
    NSURLRequest  *request=[NSURLRequest requestWithURL:url];
    [wbView loadRequest:request];
    [self setUpNavigationBarItem];
    
    _view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _view.center=self.view.center;
    _view.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_view];
    

    _imgView=[[UIImageView alloc]initWithFrame:CGRectMake(20, 15, 20, 20)];
    _imgView.image=[UIImage imageNamed:@"blue_v"];
    _imgView.layer.cornerRadius=10;
    _imgView.backgroundColor=[UIColor redColor];
    [_view addSubview:_imgView];
    
    _label=[[UILabel alloc]initWithFrame:CGRectMake(10, 36, 40, 15)];
    _label.font=[UIFont systemFontOfSize:10];
    _label.textAlignment=NSTextAlignmentCenter;
    _label.textColor=[UIColor whiteColor];
    _label.text=@"感兴趣";
    [_view addSubview:_label];
    [_view setHidden:YES];
}

-(void)setUpNavigationBarItem
{
    NSMutableArray *rightBtnArr=[NSMutableArray array];
     NSArray *rightBtnImage=@[@"navigationBarItem_like_normal",@"navigationBarItem_favorite_normal",@"navigationbar_share_icon"];
    UIBarButtonItem *backBtn=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"navigationbar_back_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(leftBtnClick:)];
    self.navigationItem.leftBarButtonItem=backBtn;
    for (int i=2; i>=0; i--) {
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:rightBtnImage[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick:)];
        rightBtn.tag=100+i;
        [rightBtnArr addObject:rightBtn];
    }
    self.navigationItem.rightBarButtonItems=rightBtnArr;
}
-(void)leftBtnClick:(UIBarButtonItem *)leftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnClick:(UIBarButtonItem *)righBtn
{
   if(righBtn.tag==102)
   {
       //友盟分享
       [UMSocialSnsService presentSnsIconSheetView:self appKey:@"507fcab25270157b37000010" shareText:@"1111" shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToDouban,UMShareToWhatsapp,UMShareToLine,UMShareToQQ,UMShareToQzone,nil] delegate:nil];
       
   }
   else if(righBtn.tag==101)
   {
       if (_clickCount==0) {
           [righBtn setImage:[[UIImage imageNamed:@"navigationBarItem_favorited_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
           _label.text=@"搜藏成功";
           [_view setHidden:NO];
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               _view.hidden=YES;
           });
           //将网页网址存入沙盒目录
           if ([[NSFileManager defaultManager]fileExistsAtPath:[_sandBoxString stringByAppendingPathComponent:@"url.plist"]])
           {
               [_plistArr addObjectsFromArray:[[NSArray alloc]initWithContentsOfFile:[_sandBoxString stringByAppendingPathComponent:@"url.plist"]]];
           }
         
           NSDate *date=[NSDate date];
           NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
           [formatter setDateFormat:@"MM-dd,hh:mm"];
           NSString *dateStr=[formatter stringFromDate:date];
           NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:self.url,@"url",self.tittleStr,@"tittle", dateStr,@"date",nil];
           [_plistArr addObject:dict];
           [_plistArr writeToFile:[_sandBoxString stringByAppendingPathComponent:@"url.plist"] atomically:YES];
           _clickCount=1;
       }
       else{
           [_plistArr removeObject:[_plistArr lastObject]];
           [_plistArr writeToFile:[_sandBoxString stringByAppendingPathComponent:@"url.plist"] atomically:YES];
           _clickCount=0;
       }
   }
   else{
       [righBtn setImage:[[UIImage imageNamed:@"navigationBarItem_favorited_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
       _label.text=@"感兴趣";
       [_view setHidden:NO];
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           _view.hidden=YES;
       });

   }
    
}
@end
