//
//  ViewController.m
//  YYModel1.0.4源码阅读201705
//
//  Created by huangchengdu on 17/5/3.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "ViewController.h"
#import "YYModel.h"
#import "User.h"
#import "Book.h"
#import "Author.h"
#import "Attributes.h"
#import "BOOK1.h"
#import "User1.h"
#import "YYShadow.h"
@interface ViewController ()

@end

@implementation ViewController
{
    User *_user;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(id)convertStringToJSON:(NSString *)modelName{
    NSString *path = [[NSBundle mainBundle] pathForResource:modelName ofType:@"txt"];
    NSString *JSONString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    return result;
}

/**
 将JSON转换为Model

 @param sender <#sender description#>
 */
- (IBAction)ClickButton1:(id)sender {
    
    NSDictionary *dic = [self convertStringToJSON:@"Model1"];
    NSLog(@"%@",dic);
    User *user = [User yy_modelWithJSON:dic];
    _user = user;
    NSLog(@"%@",user);
}

/**
 将Model转换为JSON

 @param sender <#sender description#>
 */
- (IBAction)ClickButton2:(id)sender {
    NSString *dic = [_user yy_modelToJSONString];
    NSLog(@"%@",dic);
}

/**
 Model 包含其他 Model

 @param sender <#sender description#>
 */
- (IBAction)ClickButton3:(id)sender {
    NSDictionary *dic = [self convertStringToJSON:@"Model2"];
    Book *book = [Book yy_modelWithJSON:dic];
    NSLog(@"%@",dic);
    NSLog(@"%@",book);
}

/**
 容器类属性

 @param sender <#sender description#>
 */
- (IBAction)ClickButton4:(id)sender {
    NSDictionary *dic = [self convertStringToJSON:@"Model3"];
    NSLog(@"%@",dic);
    Attributes *attri = [Attributes yy_modelWithJSON:dic];
    NSLog(@"%@--%@",attri,attri.authors[@"first"].name);
}

/**
 属性名和JSON中的Key不同

 @param sender <#sender description#>
 */
- (IBAction)ClickButton5:(id)sender {
    NSDictionary *dic = [self convertStringToJSON:@"Model4"];
    NSLog(@"%@",dic);
    BOOK1 *book = [BOOK1 yy_modelWithJSON:dic];
    NSLog(@"%@",book);
}

/**
 数据校验与自定义转换

 @param sender <#sender description#>
 */
- (IBAction)ClickButton6:(id)sender {
    NSDictionary *dic = [self convertStringToJSON:@"Model5"];
    NSLog(@"%@",dic);
    User1 *user1 = [User1 yy_modelWithJSON:dic];
    NSLog(@"%@",user1);
    
}

/**
 Coding/Copying/hash/equal/description

 @param sender <#sender description#>
 */
- (IBAction)ClickButton7:(id)sender {
    
    NSDictionary *dic = [self convertStringToJSON:@"Model6"];
    NSLog(@"%@",dic);
    YYShadow *shadow = [YYShadow yy_modelWithJSON:dic];
    YYShadow *shadowCopy = [shadow copy];
    shadowCopy.name = @"TEST";
    //===================归档测试====================
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shadow];
    YYShadow *shadowArchiver = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"归档和复制测试：%@---%@---%@",shadow,shadowCopy,shadowArchiver);
    
    
}
@end
