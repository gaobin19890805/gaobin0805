//
//  picturePublicCollectionViewCellCollectionViewCell.m
//  Sina
//
//  Created by qianfeng on 15/6/4.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "picturePublicCollectionViewCell.h"
#import "Header.h"
#import "DataRequestManager.h"
#import "UIImageView+AFNetworking.h"
#import "MJRefresh.h"
#import "PicturePublicTableViewCell.h"
#import "PictureTwoTableViewCell.h"
#import "PictureThreeTableViewCell.h"
@interface picturePublicCollectionViewCell ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tbView;
    NSMutableArray *_dataArr;
    NSArray *_URLarr;
    //设置页数
    NSInteger _page;
    
    //设置存储已经下载数据的字典
    NSMutableDictionary *_dataDict;
    
    //记录已经加载的页面
    NSMutableDictionary *_pageDict;
    
     NSString *_sandBox;
}
@end
@implementation picturePublicCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self createTabView];
    }
    return self;
}
//创建表格
-(void)createTabView
{
    _dataDict=[NSMutableDictionary dictionary];
    _pageDict=[NSMutableDictionary dictionary];
    //请求网址数组
    _URLarr=@[URL_PICTURE_JINGXUAN,URL_PICTURE_QIQU,URL_PICTURE_MEINV,URL_PICTURE_GUSHI];
    //创建表格
    _tbView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-69)];
    _tbView.showsVerticalScrollIndicator=NO;
    _tbView.delegate=self;
    _tbView.dataSource=self;
    _tbView.tableFooterView=[[UIView alloc]init];
    [self addSubview:_tbView];
    UINib *nib=[UINib nibWithNibName:@"PicturePublicTableViewCell" bundle:nil];
    [_tbView registerNib:nib forCellReuseIdentifier:@"one"];
    UINib *nibTwo=[UINib nibWithNibName:@"PictureTwoTableViewCell" bundle:nil];
    [_tbView registerNib:nibTwo forCellReuseIdentifier:@"two"];
    UINib *nibThree=[UINib nibWithNibName:@"PictureThreeTableViewCell" bundle:nil];
    [_tbView registerNib:nibThree forCellReuseIdentifier:@"three"];
    [_tbView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing) dateKey:nil];
    [_tbView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
    NSArray *arr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _sandBox=[arr lastObject];
}
//下拉刷新
-(void)headerRefreshing
{
    [_dataArr removeAllObjects];
    _page=1;
    //获取当前 cell 的 index
    NSIndexPath *index=[(UICollectionView *)self.superview indexPathForCell:self];
    [self requestURl:index andPage:_page];
   // NSLog(@"%li",_page);
    //为不同页面的最后刷新时间添加相应的 Key
    _tbView.header.dateKey=[NSString stringWithFormat:@"%li",index.item];
}
//上拉加载
-(void)footerRefreshing
{
    
    NSIndexPath *index=[(UICollectionView *)self.superview indexPathForCell:self];
    _page=[[_pageDict objectForKey:[NSNumber numberWithInteger:index.item]]integerValue];
    NSLog(@"%li",_page);
    [self requestURl:index andPage:++_page];
   NSLog(@"%li",_page);
    
}

-(void)showCollectionViewCell:(NSIndexPath *)indexPath
{
    [_tbView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    [_tbView.header setTitle:@"刷新成功" forState: MJRefreshHeaderStateIdle];
    if ([_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.item]]==nil) {
        //添加数据 为每个 collectionCell 创建数据源数据
        _dataArr=[[NSMutableArray alloc]init];
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"pictures_%li",indexPath.item]]]) {
            _dataDict=[NSKeyedUnarchiver unarchiveObjectWithFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"pictures_%li",indexPath.item]]];
            _dataArr=[_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.item]];
            [_tbView reloadData];
        }
        //cell加载即开始刷新表格
        [_tbView.header beginRefreshing];
    }
    else
    {
        //表格只要取到值 就刷新数据
        _dataArr=[_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.item]];
        [_tbView reloadData];
    }
}
//请求数据
-(void) requestURl:(NSIndexPath *)indexPath andPage:(NSInteger)page
{
    AFHTTPRequestOperationManager *manager=[DataRequestManager shareHTTPRequestOperationManager];
    
    [manager GET:[NSString stringWithFormat:_URLarr[indexPath.item],page] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [_dataArr addObjectsFromArray:dict[@"data"][@"list"]];
        //以 item 为 key 保存每页加载的数据源
        [_dataDict setObject:_dataArr forKey:[NSString stringWithFormat:@"%li",indexPath.item]];
        //将最新数据进行缓存
        if (_page==1) {
            //归档首页文件
            [NSKeyedArchiver archiveRootObject:_dataDict toFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"pictures_%li",indexPath.item]]];
        }
        //存储加载的页数
        [_pageDict setObject:[NSNumber numberWithInteger:page] forKey:[NSNumber numberWithInteger:(NSInteger)indexPath.item]];
        //刷新表格
        [_tbView reloadData];
        //停止刷新
        [_tbView.header endRefreshing];
        [_tbView.footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"%@",error.localizedDescription);
    }];
}
//返回表格的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
   
}
//创建表格 cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArr.count!=0) {
   if ([_dataArr[indexPath.row][@"pics"][@"picTemplate"]intValue]==2) {
        PicturePublicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"one"];
       [cell.oneimgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][0][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
       cell.oneimgView.layer.borderColor=[UIColor clearColor].CGColor;
       [cell.secondImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][1][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
       cell.secondImgView.layer.borderColor=[UIColor whiteColor].CGColor;

       [cell.threeImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][2][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
       cell.tittleLabel.text=_dataArr[indexPath.row][@"title"];
       cell.introLabel.text=_dataArr[indexPath.row][@"intro"];
       return cell;
    }
    
    else if ([_dataArr[indexPath.row][@"pics"][@"picTemplate"]intValue]==3) {
        PictureTwoTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"two"];
        [cell.firstImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][0][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
        [cell.sencondImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][1][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
        [cell.thirdImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][2][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.ong"]];
        cell.tittleLabel.text=_dataArr[indexPath.row][@"title"];
        cell.introLabel.text=_dataArr[indexPath.row][@"intro"];
        return cell;
    }
    else {
        PictureThreeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"three"];
        [cell.firstImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][0][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.ong"]];
        [cell.secondImgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pics"][@"list"][1][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.ong"]];
        cell.tittleLabel.text=_dataArr[indexPath.row][@"title"];
        cell.introLabel.text=_dataArr[indexPath.row][@"intro"];
        return cell;
    }
    }
    else{
        static NSString *str=@"Cell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:str];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        }
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataArr[indexPath.row][@"pics"][@"picTemplate"]intValue]==2){
    return 350;
    }
    else
        return 260;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str=_dataArr[indexPath.row][@"link"];
    NSString *tittleStr=_dataArr[indexPath.row][@"title"];
    NSArray *strArr=@[str,tittleStr];
    //点击表格发送消息
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Picture" object:strArr];
    
}

@end