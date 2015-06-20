//
//  videoPublicCollectionViewCell.m
//  Sina
//
//  Created by qianfeng on 15/6/2.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "videoPublicCollectionViewCell.h"
#import "videoPublicTableViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "DataRequestManager.h"
#import "MJRefresh.h"
#import "Header.h"
#import <MediaPlayer/MediaPlayer.h>

@interface  videoPublicCollectionViewCell()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tbView;
    NSMutableArray *_dataArr;
    NSArray *_urlArr;
    NSInteger _page;
    NSMutableDictionary *_dataDict;
    NSMutableDictionary *_pageDict;
    
    //视屏播放器
    MPMoviePlayerViewController *_playerController;
    UIActivityIndicatorView *_acView;
    
    //上一次点击的 cell
    videoPublicTableViewCell *_lastCell;
    NSString *_sandBox;
}
@end
@implementation videoPublicCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self createTabView];
    }
    return self;
}
-(void)createTabView
{
    _dataDict=[NSMutableDictionary dictionary];
    _pageDict=[NSMutableDictionary dictionary];
    _urlArr=@[URL_JINGGUAN,URL_VIDIO_GAOXIAO,URL_XIANCHANG,URL_HUAXU];
    _tbView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:_tbView];
    UINib *nib=[UINib nibWithNibName:@"videoPublicTableViewCell" bundle:nil];
    [_tbView registerNib:nib forCellReuseIdentifier:@"Cell"];
    _tbView.delegate=self;
    _tbView.dataSource=self;
    _tbView.tableFooterView=[[UIView alloc]init];
    _tbView.rowHeight=230;
    [_tbView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerreRreshing)];
    [_tbView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerReRreshing)];
    NSArray *arr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _sandBox=[arr lastObject];
}
-(void)headerreRreshing
{
    [_dataArr removeAllObjects];
    //移除视频播放器
    [_playerController.view removeFromSuperview];
    //将最后的 cell 设置为可点击状态
    _lastCell.userInteractionEnabled=YES;
    [_lastCell.imgView setHidden:NO];
    
    NSIndexPath *index=[(UICollectionView *)self.superview indexPathForCell:self];
    _tbView.header.dateKey=[NSString stringWithFormat:@"%li",index.item];
    _page=1;
    [self requesetURL:index andPage:_page];
}
-(void)footerReRreshing
{
    //移除视频播放器
    [_playerController.view removeFromSuperview];
    //上次点击的 cell 可以重新点击
    _lastCell.userInteractionEnabled=YES;

    NSIndexPath *index=[(UICollectionView *)self.superview indexPathForCell:self];
    _page=[[_pageDict objectForKey:[NSString stringWithFormat:@"%li",index.item]]integerValue];
    [self requesetURL:index andPage:++_page];
    //NSLog(@"%li",_page);
}
-(void)showCollectionViewCell:(NSIndexPath *)indexPath
{
    [_tbView.header setTitle:@"刷新成功" forState:MJRefreshHeaderStateIdle];
    [_tbView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    if ([_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.row]]==nil)
    {
        _dataArr=[NSMutableArray array];
        //取出首页归档文件
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"video_%li",indexPath.item]]]) {
            _dataDict=[NSKeyedUnarchiver unarchiveObjectWithFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"video_%li",indexPath.item]]];
            _dataArr=[_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.item]];
            [_tbView reloadData];
        }

        [_tbView.header beginRefreshing];
    }
    else
    {
        _dataArr=[_dataDict objectForKey:[NSString stringWithFormat:@"%li",indexPath.row]];
        [_tbView reloadData];
    }
}

-(void)requesetURL:(NSIndexPath *)indexPath andPage:(NSInteger)page
{
    AFHTTPRequestOperationManager *manager=[DataRequestManager shareHTTPRequestOperationManager];
    NSString *str=[NSString stringWithFormat:_urlArr[indexPath.item],page];
    [manager GET:str parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [_dataArr addObjectsFromArray:dict[@"data"][@"list"]];
        [_pageDict setObject:[NSNumber numberWithInteger:page] forKey:[NSString stringWithFormat:@"%li",indexPath.item]];
        [_dataDict setObject:_dataArr forKey:[NSString stringWithFormat:@"%li",indexPath.item]];
        if (_page==1) {
            //归档首页文件
            [NSKeyedArchiver archiveRootObject:_dataDict toFile:[_sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"video_%li",indexPath.item]]];
        }
        _tbView.backgroundColor=[UIColor lightGrayColor];
        [_tbView reloadData];
        [_tbView.header endRefreshing];
        [_tbView.footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_page==0) {
            [_tbView.header setTitle:@"刷新失败" forState: MJRefreshHeaderStateIdle];
        }
        [_tbView.footer setTitle:@"加载失败" forState: MJRefreshFooterStateIdle];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _dataArr.count;
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    videoPublicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (_dataArr.count!=0) {
    [cell.imgView setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.section][@"kpic"]] placeholderImage:[UIImage imageNamed:@"a.png"]];
    cell.playNumberLabel.text=[[_dataArr[indexPath.section][@"video_info"][@"playnumber"]substringToIndex:2]stringByAppendingString:@"万播放"];
    cell.tittleLabel.text=_dataArr[indexPath.section][@"long_title"];
        cell.runTimeLabel.text=[self timeFormatted:[_dataArr[indexPath.section][@"video_info"][@"runtime"]intValue]/1000];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return 15;
}
//时间转换
- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
//选中 cell 发生事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //移除视频播放视图
     [_playerController.view removeFromSuperview];
    //设置表格上得 view 为透明色
    _lastCell.blackView.backgroundColor=[UIColor clearColor];
    //上次点击的 cell 可以重新点击
    _lastCell.userInteractionEnabled=YES;
    [_lastCell.imgView setHidden:NO];
    //找到当前所点击的 cell
    videoPublicTableViewCell *cell=(videoPublicTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.imgView setHidden:YES];
    //将当前 cell 置身为不可点击
    cell.userInteractionEnabled=NO;
    //添加播放器
    _playerController=[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:_dataArr[indexPath.section][@"video_info"][@"url"]]];
    _playerController.view.frame=cell.frame;
    //播放器下面添加 view 置为黑色
    cell.blackView.backgroundColor=[UIColor blackColor];
    //播放器控制器样式 
    _playerController.moviePlayer.controlStyle=MPMovieControlStyleEmbedded;
    //滚动视图添加
    [self addSubview:_playerController.view];
   
    
    _acView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _acView.center=CGPointMake(_playerController.view.frame.size.width/2, _playerController.view.frame.size.height/2-10);
    [_playerController.view addSubview:_acView];
    [_acView startAnimating];
    //更新最终的 cell
    _lastCell=cell;
    //网络加载监听
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadStateChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
}

//判断视屏网络加载状态
-(void)loadStateChange:(NSNotification *)notification
{
    if ([_playerController.moviePlayer loadState]!=MPMovieLoadStateUnknown) {
        
        [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
          [_playerController.moviePlayer play];
        //播放改变背景色
        _lastCell.blackView.backgroundColor=[UIColor clearColor];
          [_acView removeFromSuperview];
//        [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
//      [self.superview.superview setFrame:CGRectMake(0, 0, 480, 320)];
//    [self.superview.superview setCenter:CGPointMake(160, 240)];
//       [self.superview.superview setTransform:CGAffineTransformMakeRotation(M_PI/2)];
//    [_playerController.view setFrame:CGRectMake(0, 0, 480, 320)];
//      _playerController.view.frame=self.superview.superview.bounds;
    }
    
}
//滚动表格
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //播放器跟随表格滚动
    _playerController.view.frame=CGRectMake(0, _lastCell.frame.origin.y-scrollView.contentOffset.y, _lastCell.frame.size.width, _lastCell.frame.size.height);
    //当视频播放器滚出屏幕 使其移除 并使当前 cell 可再次点击
    if (scrollView.contentOffset.y>_lastCell.frame.origin.y+_lastCell.frame.size.height) {
        [_playerController.view  removeFromSuperview];
        _lastCell.blackView.backgroundColor=[UIColor clearColor];
        _lastCell.userInteractionEnabled=YES;
        _lastCell.imgView.hidden=NO;
    }
   
}

@end
