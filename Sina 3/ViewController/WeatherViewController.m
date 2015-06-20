//
//  WeatherViewController.m
//  Sina
//
//  Created by qianfeng on 15/6/9.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "WeatherViewController.h"
#import "AnimationTool.h"
#import "addCityViewController.h"
#import "DataRequestManager.h"
@interface WeatherViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tbView;
    UIView *_cityView;
   // NSMutableArray *_cityArr;
    int clickCout;
    UIBarButtonItem *_rightBtn;
    UIBarButtonItem *_backBtn;
    UIScrollView *_sView;
}
@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //weather_indicator_down weather_indicator_up navigationbar_refresh_icon
    _cityArr=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"city"]];
     _backBtn=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"navigationbar_back_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(leftBtnClick:)];
    self.navigationItem.leftBarButtonItem=_backBtn;
    
    UIButton *tittleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    tittleBtn.frame = CGRectMake(0, 0, 100, 40);
    [tittleBtn setTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"btnTittle"]
 forState: UIControlStateNormal];
    tittleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    [tittleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tittleBtn setImage:[UIImage imageNamed:@"weather_indicator_down"]
               forState:UIControlStateNormal];
    tittleBtn.imageEdgeInsets = UIEdgeInsetsMake(10,75, 10, 10);
    tittleBtn.tag=1000;
    [tittleBtn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView=tittleBtn;
    
    _rightBtn=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"navigationbar_refresh_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick:)];
    self.navigationItem.rightBarButtonItem=_rightBtn;
    
    _cityView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _tbView=[[UITableView alloc]initWithFrame:_cityView.bounds style:UITableViewStylePlain];
    _tbView.delegate=self;
    _tbView.dataSource=self;
    _tbView.scrollEnabled=NO;
    _tbView.editing=YES;
    //允许在编辑状态下选中
    _tbView.allowsSelectionDuringEditing = YES;
    //_tbView.backgroundColor=[UIColor redColor];
    [self.view addSubview:_cityView];
    [_cityView addSubview:_tbView];
    _cityView.hidden=YES;
    _cityView.userInteractionEnabled=YES;
}

-(void)titleClick:(UIButton *)btn
{
    if (clickCout==0) {
        _cityView.hidden=NO;
        clickCout=1;
        //划入动画
        [_cityView.layer addAnimation:[AnimationTool animationIn] forKey:nil];
        [btn setImage:[UIImage imageNamed:@"weather_indicator_up"]
                   forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem=nil;
        [_backBtn setImage:nil];
    }
    else{
        _cityView.hidden=YES;
        clickCout=0;
        //划出动画
        [btn setImage:[UIImage imageNamed:@"weather_indicator_down"]
             forState:UIControlStateNormal];
        [_cityView.layer addAnimation:[AnimationTool animationOut] forKey:nil];
        [_backBtn setImage:[[UIImage imageNamed:@"navigationbar_back_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.navigationItem.rightBarButtonItem=_rightBtn;
    }
    
}
-(void)rightBtnClick:(UIBarButtonItem *)btn
{
    
}
-(void)leftBtnClick:(UIBarButtonItem *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return _cityArr.count;
    }
    else
        return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    if (indexPath.section==0) {
        cell.textLabel.text=_cityArr[indexPath.row];

    }
    else
    {
        cell.textLabel.text=@"点击添加新城市";
    }
    return cell;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return UITableViewCellEditingStyleDelete;
    }
    else{
        return UITableViewCellEditingStyleInsert;
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleInsert) {
        addCityViewController *addCityController=[[addCityViewController alloc]init];
        [addCityController backData:^(NSString *str) {
            //遍历数组
            NSArray *arr=[_cityArr copy];
            if (arr.count==0) {
                [_cityArr addObject:str];
            }
            else{
                for (int i=0;i<arr.count;i++) {
                    if ([arr[i] rangeOfString:str].location!=NSNotFound) {
                        return ;
                    }
                    else{
                        if (i==arr.count-1) {
                            [_cityArr addObject:str];
                        }
                    }
                }
            }
            [[NSUserDefaults standardUserDefaults]setObject:_cityArr forKey:@"city"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [_tbView reloadData];
        }];
        [self.navigationController pushViewController:addCityController animated:YES];
    }
    else {
        [_cityArr removeObjectAtIndex:indexPath.row];
        [_tbView  deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [[NSUserDefaults standardUserDefaults]setObject:_cityArr forKey:@"city"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section==1) {
        addCityViewController *addCityController=[[addCityViewController alloc]init];
        [addCityController backData:^(NSString *str) {
            NSArray *arr=[NSArray arrayWithArray:_cityArr];
            if (arr.count==0) {
                [_cityArr addObject:str];
            }
            else{
            for (int i=0;i<arr.count;i++) {
                if ([arr[i] rangeOfString:str].location!=NSNotFound) {
                    return ;
                }
                else{
                    if (i==arr.count-1) {
                        [_cityArr addObject:str];
                    }
                }
              }
            }
            [[NSUserDefaults standardUserDefaults]setObject:_cityArr forKey:@"city"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [_tbView reloadData];
                   }];
        [self.navigationController pushViewController:addCityController animated:YES];
    }
    else if(indexPath.section==0)
    {
        _cityView.hidden=YES;
        clickCout=0;
        [_cityView.layer addAnimation:[AnimationTool animationOut] forKey:nil];
        [_backBtn setImage:[[UIImage imageNamed:@"navigationbar_back_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.navigationItem.rightBarButtonItem=_rightBtn;
       
        
        //改变 navigatiiobar tittleBtn的 标题
        UIButton *btn=(UIButton *)self.navigationItem.titleView;
        [btn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        AFHTTPRequestOperationManager *manager=[DataRequestManager shareHTTPRequestOperationManager];
//        [manager GET:[NSString stringWithFormat:@"http://api.36wu.com/Weather/GetWeatherByIp?cityname=%@&format=json",cell.textLabel.text] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//            self.temperatureLabel.text=dict[@"data"][@"temp"];
//            self.maxMinLabel.text=[NSString stringWithFormat:@"%@/%@",dict[@"data"][@"maxTemp"],dict[@"data"][@"minTemp"]];
//            self.windLabel.text=dict[@"data"][@"windDirection"];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//        }];
        //存储当前城市
        [[NSUserDefaults standardUserDefaults]setObject:cell.textLabel.text forKey:@"btnTittle"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=NO;
    self.view.backgroundColor=[UIColor redColor];
}

@end
