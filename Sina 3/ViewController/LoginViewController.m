//
//  LoginViewController.m
//  Sina
//
//  Created by qianfeng on 15/6/11.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
@interface LoginViewController ()<UIWebViewDelegate,MBProgressHUDDelegate>
{
    UIWebView *_webView;
    MBProgressHUD *hud;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/authorize?client_id=1380687943&redirect_uri=http://www.baidu.com&response_type=code"];
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    [_webView loadRequest:request];
    _webView.delegate=self;
    [self.view addSubview:_webView];
    hud=[[MBProgressHUD alloc]initWithView:self.view];
    //hud.color=[UIColor clearColor];
    [self.view addSubview:hud];
    hud.labelText=@"加载中";
    hud.delegate=self;
    [hud show:YES];
    
}
-(void)btnClick:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud removeFromSuperview];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 30, 60, 30);
    [btn setTitle:@"退出" forState: UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    // btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_webView addSubview:btn];
}



@end
