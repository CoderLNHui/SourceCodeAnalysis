//
//  ViewController.m
//  CoderLN-AFNetworking
//
//  Created by LN on 2019/3/3.
//  Copyright © 2019年 不知名开发者. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSString * urlStr = @"https://github.com/CoderLN/Apple-GitHub-Codeidea";
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    // afn_GET
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

    
    
    // afn_POST
    NSDictionary * parameters = @{
                                @"username":@"",
                                @"pwd":@"",
                                @"type":@"JSON"
                                };
    [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}













- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
