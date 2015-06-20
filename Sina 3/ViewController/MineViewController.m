//
//  MineViewController.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "MineViewController.h"
#import "MyNavigationController.h"
#import "AFNetworking.h"
#import <StoreKit/StoreKit.h>
#import "FavoriateViewController.h"
#import "WeatherViewController.h"
#import "LoginViewController.h"
@interface MineViewController()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITableView *_tbView;
    NSArray *_tittleArr;
    NSArray *_btnArr;
    BOOL _status;
    MyNavigationController *nav;
    //缓存文件
    NSString *_caches;
    //页面顶头背景
    UIView *view;
}
@end
@implementation MineViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _btnArr=@[@"收藏",@"评论",@"最低17°"];
    _tittleArr=@[@"离线下载",@"夜间模式",@"头条推送",@"仅Wi-Fi下载图片",@"正文字号",@"清除缓存",@"评分",@"反馈",@"关于"];
    
    _tbView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
   
    _tbView.delegate=self;
    _tbView.dataSource=self;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.navigationController.navigationBar.hidden=YES;
    [self.view addSubview:_tbView];
    [self setUpHearderView];
    //查找到缓存目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _caches=[paths lastObject];
    NSLog(@"%@",_caches);
   
}
//点击表格执行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return 6;
    }
    else if(section==2){
        return 3;
    }
    else
        return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIntentifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:strIntentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIntentifier];
    }
    if (indexPath.section==1) {
        //cell.selectionStyle=UITableViewCellSelectionStyleGray;
        cell.textLabel.text=_tittleArr[indexPath.row];
        if (indexPath.row==0||indexPath.row==4) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row==5) {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
            label.textColor=[UIColor lightGrayColor];
            label.tag=10000;
            [label setTextAlignment:NSTextAlignmentRight];
            //页面加载时调用
            float size=[self folderSizeAtPath:[_caches stringByAppendingPathComponent:@"Dream.Sina"]];
            label.text=[NSString stringWithFormat:@"%.2fMB",size];
            label.font=[UIFont systemFontOfSize:15];
            cell.accessoryView=label;
        }
        else
        {
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            UISwitch *sw=[[UISwitch alloc]init];
            sw.tag=1000+indexPath.row;
            [sw addTarget:self action:@selector(swOn:) forControlEvents:UIControlEventValueChanged];
            if (indexPath.row==1) {
                [sw setOn:NO];
            }
            else{
            [sw setOn:YES];
            }
            cell.accessoryView=sw;
        }
    }
    else if(indexPath.section==2){
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=_tittleArr[indexPath.row+6];
    }
    return cell;
}
-(void)swOn:(UISwitch *)sw
{
    if (sw.tag-1000==3) {
        if (sw.isOn==YES) {
            NSString *str=@"1";
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchIsOn" object:str];
        }
        else
        {
            NSString *str=@"0";
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchIsOn" object:str];
        }
    }
}
//点击表格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    //点击删除文件
    if (indexPath.section==1&&indexPath.row==5) {
        NSString *caches=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        [self removeFile:[caches stringByAppendingPathComponent:@"Dream.Sina"]];
        float size=[self folderSizeAtPath:[caches stringByAppendingPathComponent:@"Dream.Sina"]];
        UILabel *lable=(UILabel *)cell.accessoryView;
        lable.text=[NSString stringWithFormat:@"%.2fMB",size];
    }
    else if (indexPath.section==2&&indexPath.row==0)
    {
//        NSString *str =@"https://itunes.apple.com/cn/app";
//        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        SKStoreProductViewController *sp=[[SKStoreProductViewController alloc]init];
        [sp loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"562206389"} completionBlock:^(BOOL result, NSError *error) {
            if(result){
                [self.navigationController pushViewController:sp animated:YES];
            }
        }];
        
    }
}
//计算缓存大小
-(float)folderSizeAtPath:(NSString*) folderPath
{
    //创建文件管理单例
    NSFileManager *manager=[NSFileManager defaultManager];
    //判断所查找的文件缓存目录是否存在
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    //声明文件遍历枚举器
    NSEnumerator *childFileEnumrator=[[manager subpathsAtPath:folderPath]objectEnumerator];
    NSString *fileName;
    long long folderSize=0;
    //开始遍历
    while ((fileName = [childFileEnumrator nextObject]) != nil){
       // NSLog(@"%@",fileName);
        //拼接文件路劲
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    //返回文件大小
    return folderSize/(1024.0*1024.0);
}
//获取每个文件的大小
- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        //返回文件大小
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//清除文件
-(void)removeFile:(NSString *)folderPath
{
    NSFileManager *manager=[NSFileManager defaultManager];
    NSEnumerator *childFileEnumerator=[[manager subpathsAtPath:folderPath]objectEnumerator];
    NSString *fileName;
    while ((fileName=[childFileEnumerator nextObject])!=nil) {
        NSString  *fileAbsolutePath=[folderPath stringByAppendingPathComponent:fileName];
        //移除文件
        [manager removeItemAtPath:fileAbsolutePath error:nil];
    }
}
//构建表头
-(void)setUpHearderView
{
    
    view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    view.backgroundColor=[UIColor orangeColor];
    _tbView.tableHeaderView=view;
    for (int i=0; i<3; i++) {
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3*i, 150, [UIScreen mainScreen].bounds.size.width/3, 50)];
        UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake((btn.frame.size.width)*i-1, 150, 1, 50)];
        lineView.backgroundColor=[UIColor lightGrayColor];
        [btn setTitle:_btnArr[i] forState:UIControlStateNormal];
        btn.tag=100+i;
        btn.backgroundColor=[UIColor whiteColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [view addSubview:btn];
        [view addSubview:lineView];
        //添加点击方法
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIButton *btn=[[UIButton alloc]init];
    btn.frame=CGRectMake(0, 0, 100, 100);
    btn.center=CGPointMake([UIScreen mainScreen].bounds.size.width/2, 75);
    [btn setImage:[UIImage imageNamed:@"commentdefault"] forState:UIControlStateNormal];
    [btn setTitle:@"登陆账号" forState: UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:17];
    btn.titleEdgeInsets=UIEdgeInsetsMake(90, -70, 10, 0);
    btn.layer.cornerRadius=25;
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    btn.tag=805;
    [btn addTarget:self action:@selector(headerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
}
-(void)headerBtnClick:(UIButton *)btn
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录",@"设置头像", nil];
    [alertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        LoginViewController *loginController=[[LoginViewController alloc]init];
        loginController.view.backgroundColor=[UIColor whiteColor];
        loginController.hidesBottomBarWhenPushed=YES;
        [self presentViewController:loginController animated:YES completion:nil];
    }
    if (buttonIndex==2) {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"进入相册" otherButtonTitles:@"相机", nil];
        [actionSheet showInView:self.view];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        UIImagePickerController *imgController=[[UIImagePickerController alloc]init];
        imgController.delegate=self;
        [self presentViewController:imgController animated:YES completion:nil];
    }
    if (buttonIndex==1) {
        //判断当前设备摄像头是否能用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //打开照相机
            UIImagePickerController *pikerController=[[UIImagePickerController alloc]init];
            //设置相片来源
            pikerController.sourceType=UIImagePickerControllerSourceTypeCamera;
            //设置图片是否允许编辑处理
            pikerController.allowsEditing=YES;
            pikerController.delegate=self;
            //显示照相机
            [self presentViewController:pikerController animated:YES completion:^{
                
            }];
            
        }
        else
        {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"警告" message:@"当前设备不能用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIButton *btn=(UIButton *)[view viewWithTag:805];
    UIImage *img;
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
        img=[info objectForKey:@"UIImagePickerControllerEditedImage"];
        
    }
    else
    img=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [btn setImage:img forState:UIControlStateNormal];
    
    
}
//搜藏等按钮点击事件
-(void)btnClick:(UIButton *)btn
{
    if (btn.tag==100) {
        FavoriateViewController *fa=[[FavoriateViewController alloc]init];
        fa.view.backgroundColor=[UIColor whiteColor];
        fa.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:fa animated:YES];
    }
    if (btn.tag==102) {
        WeatherViewController *weatherController=[[WeatherViewController alloc]init];
        weatherController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:weatherController animated:YES];
    }
}

//滚动视图 改变状态栏
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y>=150) {
        _status=YES;
        //系统自动调用改变状态栏样式的方法
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else
        _status=NO;
    [self setNeedsStatusBarAppearanceUpdate];
}
//返回状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle
{
    if (_status) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=YES;
    UILabel *label=(UILabel *)[_tbView viewWithTag:10000];
    //调用计算缓存的方法
   
    //计算缓存大小 拼接路径
    float size=[self folderSizeAtPath:[_caches stringByAppendingPathComponent:@"Dream.Sina"]];
    label.text=[NSString stringWithFormat:@"%.2fMB",size];
    label.font=[UIFont systemFontOfSize:15];

}
@end
