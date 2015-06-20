//
//  DataRequestManager.m
//  Sina
//
//  Created by qianfeng on 15/6/1.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import "DataRequestManager.h"

@implementation DataRequestManager
+(AFHTTPRequestOperationManager *)shareHTTPRequestOperationManager
{
    static AFHTTPRequestOperationManager *manager=nil;
    if (manager==nil) {
        manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer=[AFHTTPResponseSerializer serializer];
        manager.requestSerializer.cachePolicy=NSURLRequestReturnCacheDataElseLoad;
    }
    return manager;
}
@end
