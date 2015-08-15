//
//  XMGApp.h
//  09-掌握-多图下载
//
//  Created by xiaomage on 15/10/15.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGApp : NSObject

@property (nonatomic ,strong) NSString *name;   //app的名称
@property (nonatomic ,strong) NSString *icon;   //图标的url地址
@property (nonatomic ,strong) NSString *download;   //下载量

+(instancetype)appWithDict:(NSDictionary *)dict;
@end
