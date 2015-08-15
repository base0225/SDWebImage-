//
//  XMGApp.m
//  09-掌握-多图下载
//
//  Created by xiaomage on 15/10/15.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGApp.h"

@implementation XMGApp

+(instancetype)appWithDict:(NSDictionary *)dict
{
    //字典转模型
    XMGApp *app =[[XMGApp alloc]init];
    
    [app setValuesForKeysWithDictionary:dict];
    return app;
}
@end
