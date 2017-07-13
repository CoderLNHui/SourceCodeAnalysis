//	            __    __                ________
//	| |    | |  \ \  / /  | |    | |   / _______|
//	| |____| |   \ \/ /   | |____| |  / /
//	| |____| |    \  /    | |____| |  | |   _____
//	| |    | |    /  \    | |    | |  | |  |____ |
//  | |    | |   / /\ \   | |    | |  \ \______| |
//  | |    | |  /_/  \_\  | |    | |   \_________|
//
//	Copyright (c) 2012年 HXHG. All rights reserved.
//	http://www.jpush.cn
//  Created by Zhanghao
//

#import "SetTagsViewController.h"
#import "JPUSHService.h"

@interface SetTagsViewController () {
  CGRect _frame;
}

@end

@implementation SetTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  int fixLength;
#ifdef __IPHONE_7_0
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
    fixLength = 0;
  } else {
    fixLength = 20;
  }
#else
  fixLength = 20;
#endif
  _frame =
      CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - fixLength,
                 self.view.frame.size.width, self.view.frame.size.height);
  // Do any additional setup after loading the view from its nib.
}

- (void)analyseInput:(NSString **)alias tags:(NSSet **)tags {
  // alias analyse
  if (![*alias length]) {
    // ignore alias
    *alias = nil;
  }
  // tags analyse
  if (![*tags count]) {
    *tags = nil;
  } else {
    __block int emptyStringCount = 0;
    [*tags enumerateObjectsUsingBlock:^(NSString *tag, BOOL *stop) {
        if ([tag isEqualToString:@""]) {
          emptyStringCount++;
        } else {
          emptyStringCount = 0;
          *stop = YES;
        }
    }];
    if (emptyStringCount == [*tags count]) {
      *tags = nil;
    }
  }
}

- (IBAction)setTagsAlias:(id)sender {
  __autoreleasing NSMutableSet *tags = [NSMutableSet set];
  if (![_tags1TextField.text isEqualToString:@""] && _tags1TextField.text) {
    [self setTags:&tags addTag:_tags1TextField.text];
  }
  if (![_tags2TextField.text isEqualToString:@""] && _tags2TextField.text) {
    [self setTags:&tags addTag:_tags2TextField.text];
  }

  __autoreleasing NSString *alias = _aliasTextField.text;
  [self analyseInput:&alias tags:&tags];

  [JPUSHService setTags:tags
                 alias:alias
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                target:self];

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置"
                                                  message:@"已发送设置"
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil, nil];
  [alert show];
}

- (void)setTags:(NSMutableSet **)tags addTag:(NSString *)tag {
  //  if ([tag isEqualToString:@""]) {
  // }
  [*tags addObject:tag];
}

- (IBAction)resetTags:(id)sender {
  [JPUSHService setTags:[NSSet set]
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:self];
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:@"设置"
                                 message:@"已发送重置tags请求"
                                delegate:self
                       cancelButtonTitle:@"确定"
                       otherButtonTitles:nil, nil];
  [alert show];
}
- (IBAction)resetAlias:(id)sender {
  [JPUSHService setAlias:@""
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:self];
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:@"设置"
                                 message:@"已发送重置alias请求"
                                delegate:self
                       cancelButtonTitle:@"确定"
                       otherButtonTitles:nil, nil];
  [alert show];
}

- (void)dealloc {
}

- (IBAction)clear:(id)sender {
  _tags1TextField.text = @"";
  _tags2TextField.text = @"";
  _aliasTextField.text = @"";
}

- (IBAction)clearResult:(id)sender {
  _callBackTextView.text = @"";
}

- (IBAction)TextField_DidEndOnExit:(id)sender {
  // 隐藏键盘.
  [sender resignFirstResponder];
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap {
  // 发送resignFirstResponder.
  [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                             to:nil
                                           from:nil
                                       forEvent:nil];
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
  NSString *callbackString =
      [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode,
                                 [self logSet:tags], alias];
  if ([_callBackTextView.text isEqualToString:@"服务器返回结果"]) {
    _callBackTextView.text = callbackString;
  } else {
    _callBackTextView.text = [NSString
        stringWithFormat:@"%@\n%@", callbackString, _callBackTextView.text];
  }
  NSLog(@"TagsAlias回调:%@", callbackString);
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logSet:(NSSet *)dic {
  if (![dic count]) {
    return nil;
  }
  NSString *tempStr1 =
      [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                   withString:@"\\U"];
  NSString *tempStr2 =
      [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  NSString *tempStr3 =
      [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString *str =
      [NSPropertyListSerialization propertyListFromData:tempData
                                       mutabilityOption:NSPropertyListImmutable
                                                 format:NULL
                                       errorDescription:NULL];
  return str;
}

- (IBAction)View_TouchDown:(id)sender {
  // 发送resignFirstResponder.
  [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                             to:nil
                                           from:nil
                                       forEvent:nil];
  _backgroundView.frame = _frame;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
