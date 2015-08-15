//
//  ViewController.m
//  ZJ SDWebImage 的原理实现
//
//  Created by base on 15/09/19.
//  Copyright © 2015年 base. All rights reserved.
//

#import "ViewController.h"
#import "XMGApp.h"
@interface ViewController ()
@property (nonatomic,strong) NSArray *apps;
@property (nonatomic,strong) NSMutableDictionary *images;
@property (nonatomic,strong) NSOperationQueue *queue;
@property (nonatomic,strong) NSMutableDictionary *operations;
@end

@implementation ViewController


-(NSArray *)apps
{
    if (_apps == nil) {
        //1.加载本地文件
        NSArray *arrayM = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"apps.plist" ofType:nil]];
        
        //        NSLog(@"%@",arrayM);
        //2.字典转模型---字典数组-->模型数据
        NSMutableArray *appsM = [NSMutableArray arrayWithCapacity:arrayM.count];
        
        for (NSDictionary *dict in arrayM) {
            [appsM addObject:[XMGApp appWithDict:dict]];
        }
//        NSLog(@"%@",appsM);
        _apps = appsM;
    }
    return _apps;
}

- (NSMutableDictionary *)operations
{
    if (_operations == nil) {
        _operations = [NSMutableDictionary dictionary];
    }
    
    return _operations;
}


- (NSMutableDictionary *)images
{
    if (_images == nil) {
        
        _images = [NSMutableDictionary dictionary];
    }
    
    return _images;
}

- (NSOperationQueue *)queue
{
    if (_queue == nil) {
    
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"app";
    
    //1、创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //2、设置cell的数据
    XMGApp *app = self.apps[indexPath.row];
    //2.1给每个app的数据赋值
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
    
    //先去内存缓存池中去取，如果有，就直接用，如果没用，就去沙盒中调用
    UIImage *image = self.images[app.icon];//这个语法是什么？
//    cell.imageView.image = [UIImage imageNamed:@"Snip20151015_157.png"];
    if (image) {
        cell.imageView.image = image;
    }else
    {
        //保存一份到沙盒
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [app.icon lastPathComponent];//什么意思？
        //拼接文件的全路径
        NSString *fullPath = [caches stringByAppendingPathComponent:fileName];
        NSData *imageData = [NSData dataWithContentsOfFile:fullPath];
        imageData = nil;
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.imageView.image = image;
            [self.images setObject:image forKey:app.icon];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"Snip20151015_157.png"];
            //显示占位图片
            NSBlockOperation *download = self.operations[app.icon];
            
            if (download == nil) {
                download = [NSBlockOperation blockOperationWithBlock:^{
                    NSURL *url = [NSURL URLWithString:app.icon];
                    [NSThread sleepForTimeInterval:2.0];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    UIImage *image = [UIImage imageWithData:data];
                    //容错
                    if (image==nil) {
                        [self.operations removeObjectForKey:app.icon];
                        return ;
                    }
                    //保存到缓存中
                    [self.images setObject:image forKey:app.icon];
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        //刷新制定的行
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }];
                    
                    [self.operations removeObjectForKey:app.icon];
                    //保存文件到沙盒
                    [data writeToFile:fullPath atomically:YES];
                }];
                
                [self.queue addOperation:download];
                
                //添加到操作缓存
                [self.operations setObject:download forKey:app.icon]; 
            }

        }
       
    }
    return cell;
}

@end
