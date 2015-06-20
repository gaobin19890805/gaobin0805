//
//  DataRequestManager.h
//  Sina
//
//  Created by qianfeng on 15/6/1.
//  Copyright (c) 2015年 高斌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
@interface DataRequestManager : NSObject
+(AFHTTPRequestOperationManager *)shareHTTPRequestOperationManager;
@end
