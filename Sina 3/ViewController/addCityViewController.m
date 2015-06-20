//
//  addCityViewController.m
//  Sina
//
//  Created by qianfeng on 15/6/9.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "addCityViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
@interface addCityViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,AMapSearchDelegate,CLLocationManagerDelegate>
{
    UITableView *_tbView;
    
    //声明数据源数组
    NSMutableArray *_mutArray;
    NSMutableArray *_mArray;
    
    //声明搜索栏和搜索控制器
    UISearchBar *_searchBar;
    UISearchDisplayController *_displayController;
    
    //存放搜索结构的数据
    NSMutableArray *_searchArray;
    
    MAMapView* _mapView;
    CLLocationCoordinate2D coordinate;
    AMapSearchAPI *_search;
    
    NSString *_currentCity;
    
    CLLocationManager* _manager;
    
    //a-z
    NSArray *_keySArray;
    NSDictionary *_cityDict;
    NSArray *_mainCityArr;
    NSString *_selectStr;
    NSMutableArray *_cityArr;
}
@end

@implementation addCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //注册高德地图 api
    [MAMapServices sharedServices].apiKey=@"83b1cf99e8c445f49ec54337199c641f";
    _mapView=[[MAMapView alloc]init];
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] initWithSearchKey:@"83b1cf99e8c445f49ec54337199c641f" Delegate:self];
    
    _tbView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    _tbView.delegate=self;
    _tbView.dataSource=self;
    [self.view addSubview:_tbView];
    
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 10)];
    //[searchBar setShowsCancelButton:YES];;
   // _searchBar.translucent=YES;
    //设置searchBar 背景图
   _searchBar.barTintColor=[UIColor lightGrayColor];
    //[_searchBar setSearchBarStyle:UISearchBarStyleDefault];
    [self.view addSubview:_searchBar];
    _displayController=[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _searchBar.delegate=self;
    _displayController.searchResultsDelegate=self;
    _displayController.searchResultsDataSource=self;
    _searchArray=[NSMutableArray array];
    
    //初始化定位类 wifi定位 基站定位  a-gps定位
    _manager = [[CLLocationManager alloc] init];
    //NSLocationAlwaysUsageDescription在plist里设置提示信息
    //ios8必须写
    [_manager requestAlwaysAuthorization];
    //精确度
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    //移动10米进行第二次定位
    _manager.distanceFilter = 10;
    _manager.delegate = self;
    
    _mainCityArr=@[@"北京",@"上海",@"广州",@"深圳",@"武汉",@"重庆",@"成都",@"长沙",@"西安",@"青岛",@"太原",@"三亚"];
    _cityArr=[NSMutableArray array];
    _searchArray=[NSMutableArray array];
    [self reloadTableViewSection];
}
-(void)reloadTableViewSection
{
    NSString *plistPath=[[NSBundle mainBundle]pathForResource:@"citydict" ofType:@"plist"];
    _cityDict=[[NSDictionary alloc]initWithContentsOfFile:plistPath];
    _keySArray=[NSArray arrayWithArray:[_cityDict allKeys]];
    //数组中的字符串排序
    _keySArray = [_keySArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * str1 = obj1;
        NSString * str2 = obj2;
        return [str1 compare:str2];
    }];
    for (int i=0;i<_keySArray.count;i++) {
        NSArray *arr=_cityDict[_keySArray[i]];
        
        for (NSString *str in arr) {
            if ([str rangeOfString:@"市"].location!=NSNotFound) {
                NSString *cityStr=[str substringToIndex:str.length-1];
                [_cityArr addObject:cityStr];
            }
            else
            {
                [_cityArr addObject:str];
            }
            
        }
    }
    NSLog(@"%@",_cityArr);
    [_tbView reloadData];
}
//搜索框开始编辑时调用该方法
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
{
    _searchBar.frame=CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 10);
}
//搜索框结束编辑时调用该方法
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _searchBar.frame=CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 10);
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==_tbView) {
        return 10;
    }
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==_tbView){
    return _keySArray.count+2;
    }
    else
    {
        [_searchArray removeAllObjects];
        for (NSString *str in _cityArr) {
            if ([str rangeOfString:_searchBar.text].location!=NSNotFound) {
                [_searchArray addObject:str];
            }
        }
        return 1;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_tbView) {
        if (section==0) {
            return 1;
        }
        else if(section==1){
            return _mainCityArr.count;
        }
        else{
            return [_cityDict[_keySArray[section-2]]count];
        }
    }
    else
        return _searchArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:str];
    }
    if (tableView==_tbView) {
        if (indexPath.section==0) {
            cell.textLabel.text=_currentCity;
            return cell;
        }
        else if(indexPath.section==1){
            cell.textLabel.text=_mainCityArr[indexPath.row];
            return cell;
        }
        else{
            NSString *str=_cityDict[_keySArray[indexPath.section-2]][indexPath.row];
            if ([str rangeOfString:@"市"].location!=NSNotFound) {
                str=[str substringToIndex:str.length-1];
            }
            cell.textLabel.text=str;
            return cell;
        }

    }
    else
    {
        cell.textLabel.text=_searchArray[indexPath.row];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    _selectStr =cell.textLabel.text;
    self.bl(_selectStr);
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView==_tbView) {
        if (section==0) {
            return @"当前定位城市";
        }
        else if(section==1)
        {
            return @"主要城市";
        }
        return _keySArray[section-2];
    }
   else return @"";
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //开始定位
    [_manager startUpdatingLocation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //停止定位
    [_manager stopUpdatingHeading];
    
}
//定位回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //取得最新位置
    CLLocation* location = [locations lastObject];
    _currentCity=[NSString stringWithFormat:@"%f %f",location.coordinate.latitude,location.coordinate.longitude];
    [_tbView reloadData];
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location=[AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    regeoRequest.requireExtension = YES;
    [_search AMapReGoecodeSearch:regeoRequest];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        _currentCity = response.regeocode.addressComponent.province;
        [_tbView reloadData];
    }
}
-(void)backData:(complention)block
{
    self.bl=block;
}
@end
