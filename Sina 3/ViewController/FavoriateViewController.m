
//
//  FavoriateViewController.m
//  Sina
//
//  Created by qianfeng on 15/6/8.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "FavoriateViewController.h"
#define screenWith  [UIScreen mainScreen].bounds.size.width
#define screenHeight  [UIScreen mainScreen].bounds.size.height
#import "DetailsViewController.h"

@interface FavoriateViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tbView;
    NSMutableArray *_dataArr;
    NSString *_sandBoxString;
    BOOL isEditing;
}
@end

@implementation FavoriateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"收藏";
    _tbView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _tbView.delegate=self;
    _tbView.dataSource=self;
    _tbView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _tbView.tableFooterView = [[UIView alloc] init];
    _tbView.rowHeight=60;
    [self.view addSubview:_tbView];
    [self requestData];
    
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style: UIBarButtonItemStylePlain target:self action:@selector(rightBtnClick:)];
    self.navigationItem.rightBarButtonItem=rightBtn;
}
-(void)rightBtnClick:(UIBarButtonItem *)btn
{
    isEditing=!isEditing;
    _tbView.editing=isEditing;
}
-(void)requestData
{
    _sandBoxString=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    _dataArr=[[NSMutableArray alloc]initWithContentsOfFile:[_sandBoxString stringByAppendingPathComponent:@"url.plist"]];
    
    [_tbView reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }
    cell.textLabel.text=_dataArr[indexPath.row][@"tittle"];
    cell.detailTextLabel.text=_dataArr[indexPath.row][@"date"];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    [_dataArr removeObjectAtIndex:indexPath.row];
    [_tbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [_dataArr writeToFile:[_sandBoxString stringByAppendingPathComponent:@"url.plist"] atomically:YES];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailsViewController *de=[[DetailsViewController alloc]init];
    de.url=_dataArr[indexPath.row][@"url"];
    [self.navigationController pushViewController:de animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=NO;
}

@end
