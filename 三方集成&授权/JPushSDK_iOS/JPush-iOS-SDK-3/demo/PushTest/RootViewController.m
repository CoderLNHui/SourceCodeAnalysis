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

#import "RootViewController.h"
#import "JPUSHService.h"
#import "AppDelegate.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _messageCount = 0;
  _notificationCount = 0;
  _messageContents = [[NSMutableArray alloc] initWithCapacity:6];
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter addObserver:self
                    selector:@selector(networkDidSetup:)
                        name:kJPFNetworkDidSetupNotification
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(networkDidClose:)
                        name:kJPFNetworkDidCloseNotification
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(networkDidRegister:)
                        name:kJPFNetworkDidRegisterNotification
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(networkDidLogin:)
                        name:kJPFNetworkDidLoginNotification
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(networkDidReceiveMessage:)
                        name:kJPFNetworkDidReceiveMessageNotification
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(serviceError:)
                        name:kJPFServiceErrorNotification
                      object:nil];

// Do any additional setup after loading the view from its nib.

  _UDIDValueLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                              green:122.0 / 255
                                               blue:255.0 / 255
                                              alpha:1];
  _registrationValueLabel.text = [JPUSHService registrationID];
  _registrationValueLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                                      green:122.0 / 255
                                                       blue:255.0 / 255
                                                      alpha:1];
  // show appKey
  NSString *appKey = [self getAppKey];
  if (appKey) {
    _appKeyLabel.text = appKey;
    _appKeyLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                             green:122.0 / 255
                                              blue:255.0 / 255
                                             alpha:1];
  }
}

//获取appKey
- (NSString *)getAppKey {
  return [appKey lowercaseString];
}

- (void)dealloc {
  [self unObserveAllNotifications];
}

- (void)unObserveAllNotifications {
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter removeObserver:self
                           name:kJPFNetworkDidSetupNotification
                         object:nil];
  [defaultCenter removeObserver:self
                           name:kJPFNetworkDidCloseNotification
                         object:nil];
  [defaultCenter removeObserver:self
                           name:kJPFNetworkDidRegisterNotification
                         object:nil];
  [defaultCenter removeObserver:self
                           name:kJPFNetworkDidLoginNotification
                         object:nil];
  [defaultCenter removeObserver:self
                           name:kJPFNetworkDidReceiveMessageNotification
                         object:nil];
  [defaultCenter removeObserver:self
                           name:kJPFServiceErrorNotification
                         object:nil];
}

- (void)networkDidSetup:(NSNotification *)notification {
  _netWorkStateLabel.text = @"已连接";
  NSLog(@"已连接");
  _netWorkStateLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                                 green:122.0 / 255
                                                  blue:255.0 / 255
                                                 alpha:1];
}

- (void)networkDidClose:(NSNotification *)notification {
  _netWorkStateLabel.text = @"未连接。。。";
  NSLog(@"未连接");
  _netWorkStateLabel.textColor = [UIColor redColor];
}

- (void)networkDidRegister:(NSNotification *)notification {
  NSLog(@"%@", [notification userInfo]);
  _netWorkStateLabel.text = @"已注册";
  _netWorkStateLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                                 green:122.0 / 255
                                                  blue:255.0 / 255
                                                 alpha:1];
  _registrationValueLabel.text =
      [[notification userInfo] valueForKey:@"RegistrationID"];
  _registrationValueLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                                      green:122.0 / 255
                                                       blue:255.0 / 255
                                                      alpha:1];
  NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
  _netWorkStateLabel.text = @"已登录";
  _netWorkStateLabel.textColor = [UIColor colorWithRed:0.0 / 255
                                                 green:122.0 / 255
                                                  blue:255.0 / 255
                                                 alpha:1];
  NSLog(@"已登录");

  if ([JPUSHService registrationID]) {
    _registrationValueLabel.text = [JPUSHService registrationID];
    NSLog(@"get RegistrationID");
  }
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *title = [userInfo valueForKey:@"title"];
  NSString *content = [userInfo valueForKey:@"content"];
  NSDictionary *extra = [userInfo valueForKey:@"extras"];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

  NSString *currentContent = [NSString
      stringWithFormat:
          @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
          [NSDateFormatter localizedStringFromDate:[NSDate date]
                                         dateStyle:NSDateFormatterNoStyle
                                         timeStyle:NSDateFormatterMediumStyle],
          title, content, [self logDic:extra]];
  NSLog(@"%@", currentContent);

  [_messageContents insertObject:currentContent atIndex:0];

  NSString *allContent = [NSString
      stringWithFormat:@"%@收到消息:\n%@\nextra:%@",
                       [NSDateFormatter
                           localizedStringFromDate:[NSDate date]
                                         dateStyle:NSDateFormatterNoStyle
                                         timeStyle:NSDateFormatterMediumStyle],
                       [_messageContents componentsJoinedByString:nil],
                       [self logDic:extra]];

  _messageContentView.text = allContent;
  _messageCount++;
  [self reloadMessageCountLabel];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
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

- (void)serviceError:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *error = [userInfo valueForKey:@"error"];
  NSLog(@"%@", error);
}

- (void)addNotificationCount {
  _notificationCount++;
  [self reloadNotificationCountLabel];
}

- (void)addMessageCount {
  _messageCount++;
  [self reloadMessageCountLabel];
}

- (void)reloadMessageContentView {
  _messageContentView.text = @"";
}

- (void)reloadMessageCountLabel {
  _messageCountLabel.text = [NSString stringWithFormat:@"%d", _messageCount];
}

- (void)reloadNotificationCountLabel {
  _notificationCountLabel.text =
      [NSString stringWithFormat:@"%d", _notificationCount];
}

- (IBAction)cleanMessage:(id)sender {
  _messageCount = 0;
  _notificationCount = 0;
  [self reloadMessageCountLabel];
  [_messageContents removeAllObjects];
  [self reloadMessageContentView];
  self.notificationCountLabel.text = @"0";
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
