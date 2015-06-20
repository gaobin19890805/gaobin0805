//
//  newsPublicCollectionViewCell.m
//  Sina
//
//  Created by qianfeng on 15/5/31.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "newsPublicCollectionViewCell.h"
#import "newsPublicTableViewCell.h"
#import "newsPublicImageTableViewCell.h"
#import "DataRequestManager.h"
#import "UIImageView+AFNetworking.h"
#import "MJRefresh.h"


@interface newsPublicCollectionViewCell ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    UITableView *_tbView;
    UIScrollView *_headerScrollView;
    //滚动标题
    UILabel *_tittleLabel;
    NSMutableArray *_dataArr;
    NSArray *_URLarr;
    //设置页数
    NSInteger _page;
    
    //设置存储已经下载数据的字典
    NSMutableDictionary *_dataDict;
    
    //记录已经加载的页面
    NSMutableDictionary *_pageDict;
    //网络是否为 wifi开关状态
    NSString *_swIsOn;
    //网络是否为 wifi
    int _status;
    
    UIPageControl *_pageControl;
    
    NSTimer *_timer;
    
    NSString *_sandBox;
    
    //存储每页的滚动位置
    NSMutableDictionary *_tbViewOffSetdict;
}
@end
@implementation newsPublicCollectionViewCell
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
    _tbViewOffSetdict=[NSMutableDictionary dictionary];
    //请求网址数组
    _URLarr=@[URL_TOUTIAO,URL_YULE,URL_TIYU,URL_CAIJING,URL_KEJI,URL_GAOXIAO,URL_QICHE];
    //创建表格
    _tbView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-69)];
    _tbView.showsVerticalScrollIndicator=NO;
    _tbView.delegate=self;
    _tbView.dataSource=self;
    _tbView.tableFooterView=[[UIView alloc]init];
    [self addSubview:_tbView];
    
    
    //创建表头滚动视图
    [self setUpHeaderScrollView];
    
    
    //注册表格
    UINib *nib1=[UINib nibWithNibName:@"newsPublicTableViewCell" bundle:nil];
    [_tbView registerNib:nib1 forCellReuseIdentifier:@"ab"];
    UINib *nib2=[UINib nibWithNibName:@"newsPublicImageTableViewCell" bundle:nil];
    [_tbView registerNib:nib2 forCellReuseIdentifier:@"bc"];
    
    [_tbView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing) dateKey:nil];
    [_tbView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
    NSArray *arr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _sandBox=[arr lastObject];
    NSLog(@"%@",_sandBox);
    
    //_timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scoll) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
}
//下拉刷新
-(void)headerRefreshing
{
    [_dataArr removeAllObjects];
    _page=1;
    //获取当前 cell 的 index
    NSIndexPath *index=[(UICollectionView *)self.superview indexPathForCell:self];
    [self requestURl:index andPage:_page];
    //为不同页面的最后刷新时间添加相应的 Key
    _tbView.header.dateKey=[NSString stringWithFormat:@"%li",index.item];
}
//上拉加载
-(void)footerRefreshing
{
   
    NSIndexPath *index=[(UICollectionView *)self.superview indexPathForCell:self];
    _page=[[_pageDict objectForKey:[NSNumber numberWithInteger:index.item]]integerValue];
    [self requestURl:index andPage:++_page];
    
}

-(void)showCollectionViewCell:(NSIndexPath *)indexPath andSwitchIsOn:(NSString *)sw
{
    _swIsOn=sw;
    [_tbView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    [_tbView.header setTitle:@"刷新成功" forState: MJRefreshHeaderStateIdle];
    if ([_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.item]]==nil) {
        //添加数据 为每个 collectionCell 创建数据源数据
        _dataArr=[[NSMutableArray alloc]init];
        //取出首页归档文件
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"news_%li",indexPath.item]]]) {
            _dataDict=[NSKeyedUnarchiver unarchiveObjectWithFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"news_%li",indexPath.item]]];
            _dataArr=[_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.item]];
            [_tbView reloadData];
        }
        //获取网络监控
        [[AFNetworkReachabilityManager sharedManager]startMonitoring];
        [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            //AFNetworkReachabilityStatusReachableViaWiFi = 2,
            _status=status;
             //cell加载即开始刷新表格
            [_tbView.header beginRefreshing];
        }];
    }
    else
    {
        _tbView.contentOffset=CGPointMake(0, [[_tbViewOffSetdict objectForKey:@(indexPath.item)]floatValue]);
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
             [self showHeaderViewImage];
            //归档首页文件
            [NSKeyedArchiver archiveRootObject:_dataDict toFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"news_%li",indexPath.item]]];
        }
        //存储加载的页数
        [_pageDict setObject:[NSNumber numberWithInteger:page] forKey:[NSNumber numberWithInteger:(NSInteger)indexPath.item]];
        if (_dataArr.count>0) {
            [_tbView reloadData];
        }
        
        //停止刷新
        [_tbView.header endRefreshing];
        [_tbView.footer endRefreshing];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}
//返回表格的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataArr.count==0) {
        return 0;
    }
    else
    {
        
        return _dataArr.count-5;
    }
}
//创建表格 cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArr.count>0) {
        if (_dataArr[indexPath.row+5][@"pics"]==nil) {
            newsPublicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ab"];
            cell.titleLabel.text=_dataArr[indexPath.row+5][@"title"];
            cell.introLabel.text=_dataArr[indexPath.row+5][@"intro"];
            int total=[_dataArr[indexPath.row+5][@"comment_count_info"][@"total"]intValue];
            cell.totalLabel.text=[NSString stringWithFormat:@"%d 评论",total];
            if (_status==2&&[_swIsOn isEqualToString:@"1"]) {
                [cell.imgView setImageWithURL: [NSURL URLWithString:_dataArr[indexPath.row+5][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
            }
            else cell.imgView.image=[UIImage imageNamed:@"a.png"];
            return cell;
        }
        else {
            newsPublicImageTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"bc"];
            cell.imgTittleLabel.text=_dataArr[indexPath.row+5][@"title"];
            //判断是否为 wifi 状态
            if (_status==2&&[_swIsOn isEqualToString:@"1"]) {
            [cell.firstImgView setImageWithURL: [NSURL URLWithString:_dataArr[indexPath.row+5][@"pics"][@"list"][0][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
            [cell.secondImgView setImageWithURL: [NSURL URLWithString:_dataArr[indexPath.row+5][@"pics"][@"list"][1][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
            [cell.thirdImgView setImageWithURL: [NSURL URLWithString:_dataArr[indexPath.row+5][@"pics"][@"list"][2][@"pic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
            }
            else
            {
                cell.firstImgView.image=[UIImage imageNamed:@"a.png"];
                cell.secondImgView.image=[UIImage imageNamed:@"a.png"];
                cell.thirdImgView.image=[UIImage imageNamed:@"a.png"];
            }
            int total=[_dataArr[indexPath.row+5][@"comment_count_info"][@"total"]intValue];
            cell.conmentTotalLabel.text=[NSString stringWithFormat:@"%d 评论",total
                                         ];
            return cell;
        }
    }
    else
    {
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
    if (_dataArr.count>5) {
        if (_dataArr[indexPath.row+5][@"pics"]==nil)
        {
            return 80;
        }
        else
            return 120;
    }
    else return 0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str=_dataArr[indexPath.row+5][@"link"];
    NSString *tittleStr=_dataArr[indexPath.row+5][@"title"];
    NSArray *strArr=@[str,tittleStr];
    //点击表格发送消息
    [[NSNotificationCenter defaultCenter]postNotificationName:@"id" object:strArr];
    
}
//创建表头视图
-(void)setUpHeaderScrollView
{
    UIView *view=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 150)];
    _headerScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 150)];
    _headerScrollView.contentSize=CGSizeMake(self.frame.size.width*7, 0);
    _headerScrollView.pagingEnabled=YES;
    _headerScrollView.contentOffset=CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
    _headerScrollView.delegate=self;
    [view addSubview:_headerScrollView];
    //_headerScrollView.backgroundColor=[UIColor redColor];
    
   _tittleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 130, [UIScreen mainScreen].bounds.size.width, 20)];
    _tittleLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _tittleLabel.textColor=[UIColor whiteColor];
    _tittleLabel.font=[UIFont systemFontOfSize:12];
    [view addSubview:_tittleLabel];
   

    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-70, 130, 60, 20)];
    _pageControl.numberOfPages=5;
    _pageControl.currentPageIndicatorTintColor=[UIColor redColor];
    _pageControl.pageIndicatorTintColor=[UIColor blueColor];
    _pageControl.currentPage=0;
    [view addSubview:_pageControl];
    //_pageControl.currentPage=0;
    _tbView.tableHeaderView=view;
    _pageControl.hidden=YES;
    
    
}

//显示表格视图
-(void)showHeaderViewImage
{
    [_timer setFireDate:[NSDate distantFuture]];
    //先移除已经创建的
    for (UIImageView *  obj in [_headerScrollView subviews]) {
        [obj removeFromSuperview];
    }
    _tittleLabel.text=_dataArr[0][@"title"];
    if (_dataArr.count!=0) {
        //打开
        _pageControl.hidden=NO;
    for (int i=0; i<7; i++) {
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width*i, 0, self.frame.size.width, _headerScrollView.frame.size.height)];
        imgView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [imgView addGestureRecognizer:tap];
        if (_status==2&&[_swIsOn isEqualToString:@"1"]){
        if (i==0) {
            [imgView setImageWithURL:[NSURL URLWithString:_dataArr[4][@"kpic"]]];
        }
        else if (i==6){
            [imgView setImageWithURL:[NSURL URLWithString:_dataArr[0][@"kpic"]]];
        }
        else{
        [imgView setImageWithURL:[NSURL URLWithString:_dataArr[i-1][@"kpic"]]];
            imgView.tag=10+i-1;
        }

        }
        else
        [ imgView setImage:[UIImage imageNamed:@"a.png"]];
        [_headerScrollView addSubview:imgView];
    }
    }
   //[_timer setFireDate:[NSDate distantPast]];
}
-(void)tapClick:(UITapGestureRecognizer *)tap
{
    NSString *str=_dataArr[tap.view.tag-10][@"link"];
    NSString *tittleStr=_dataArr[tap.view.tag-10][@"title"];
    NSArray *strArr=@[str,tittleStr];
    //点击表格发送消息
    [[NSNotificationCenter defaultCenter]postNotificationName:@"id" object:strArr];
}
-(void)scoll
{
        [_headerScrollView setContentOffset:CGPointMake(_headerScrollView.contentOffset.x+[UIScreen mainScreen].bounds.size.width, 0) animated:YES];
    if (_headerScrollView.contentOffset.x>[UIScreen mainScreen].bounds.size.width*5) {
        _headerScrollView.contentOffset=CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
        _pageControl.currentPage=0;
    }
    else
    {
        _pageControl.currentPage=_pageControl.currentPage+1;
        
    }
    int i=_headerScrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    _tittleLabel.text=_dataArr[i][@"title"];

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_headerScrollView) {
        if (_headerScrollView.contentOffset.x>[UIScreen mainScreen].bounds.size.width*5) {
            _headerScrollView.contentOffset=CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
            _pageControl.currentPage=0;
            _tittleLabel.text=_dataArr[0][@"title"];
        }
        else if(_headerScrollView.contentOffset.x<320)
        {
            _headerScrollView.contentOffset=CGPointMake([UIScreen mainScreen].bounds.size.width*5, 0);
            _pageControl.currentPage=4;
            _tittleLabel.text=_dataArr[4][@"title"];
        }
        else {
            _pageControl.currentPage=_headerScrollView.contentOffset.x/320-1;
            _tittleLabel.text=_dataArr[_pageControl.currentPage][@"title"];
        }

    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSIndexPath *indexPath=[(UICollectionView *)self.superview indexPathForCell:self];
   
    [_tbViewOffSetdict setObject:@(_tbView.contentOffset.y) forKey:@(indexPath.item)];
}


@end
