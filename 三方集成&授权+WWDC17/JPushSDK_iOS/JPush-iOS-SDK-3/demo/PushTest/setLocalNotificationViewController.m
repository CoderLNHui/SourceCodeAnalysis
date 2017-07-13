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

#import "setLocalNotificationViewController.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface setLocalNotificationViewController () {
  CGRect _frame;
}
@end

@implementation setLocalNotificationViewController {
  id _notification;
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
- (IBAction)setNotification:(id)sender {
// v2.1.9版以前方式
//  _notification = [JPUSHService
//      setLocalNotification:_notificationDatePicker.date
//                 alertBody:_notificationBodyTextField.text
//                     badge:[_notificationBadgeTextField.text intValue]
//               alertAction:_notificationButtonTextField.text
//             identifierKey:_notificationIdentifierTextField.text
//                  userInfo:nil
//                 soundName:nil];
//  [self clearAllInput];
//  NSString *result;
//  if (_notification) {
//    result = @"设置本地通知成功";
//  } else {
//    result = @"设置本地通知失败";
//  }
//  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置"
//                                                  message:@"设置成功"
//                                                 delegate:self
//                                        cancelButtonTitle:@"确定"
//                                        otherButtonTitles:nil, nil];
//  [alert show];
  
  // v2.1.9版以后方式
  JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
  content.body = _notificationBodyTextField.text;
  content.badge = @([_notificationBadgeTextField.text intValue]);
  content.action = _notificationButtonTextField.text;
  JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    trigger.timeInterval = [_notificationDatePicker.date timeIntervalSinceNow]; // iOS10以上有效
  }
  else {
    trigger.fireDate = _notificationDatePicker.date; // iOS10以下有效
  }
  JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
  request.content = content;
  request.trigger = trigger;
  request.requestIdentifier = _notificationIdentifierTextField.text;
  request.completionHandler = ^(id result) {
    NSLog(@"%@", result); // iOS10以上成功则result为UNNotificationRequest对象，失败则result为nil;iOS10以下成功result为UILocalNotification对象，失败则result为nil
    _notification = result;
    if (result) {
      void (^block)() = ^() {
//      [self clearAllInput];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置"
                                                        message:@"设置成功"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
      };
      if ([NSThread isMainThread]) {
        block();
      }
      else {
        dispatch_async(dispatch_get_main_queue(), block);
      }
    }
  };
  [JPUSHService addNotification:request];
}

- (void)clearAllInput {
  _notificationBadgeTextField.text = nil;
  _notificationBodyTextField.text = @"";
  _notificationButtonTextField.text = @"";
  _notificationDatePicker.date = [[NSDate new] dateByAddingTimeInterval:0];
  _notificationIdentifierTextField.text = @"";
}

- (IBAction)clearAllNotification:(id)sender {
  // v2.1.9版以前方式
//  [JPUSHService deleteLocalNotificationWithIdentifierKey:@"test"];
//  [JPUSHService deleteLocalNotification:_notification];
//  [JPUSHService clearAllLocalNotifications];
  
  // v2.1.9版以后方式
  [JPUSHService removeNotification:nil];
//  JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
//  identifier.identifiers = @[@"test"];  // iOS10以上还需要设置delivered标志
//  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
//    identifier.notificationObj = _notification;
//  }
//  else {
//#ifdef NSFoundationVersionNumber_iOS_9_x_Max
//    UNNotificationRequest *request = _notification;
//    identifier.identifiers = @[request.identifier];  // 还需要设置delivered标志
//#endif
//  }
//  [JPUSHService removeNotification:identifier];
  
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:@"设置"
                                 message:@"取消所有本地通知成功"
                                delegate:self
                       cancelButtonTitle:@"确定"
                       otherButtonTitles:nil, nil];
  [alert show];
}

- (IBAction)clearLastNotification {
  NSString *alertMessage;
  if (_notification) {
    // v2.1.9版以前方式
//    [JPUSHService deleteLocalNotification:_notification];
    
    // v2.1.9版以后方式
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
      identifier.notificationObj = _notification;
    }
    else {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
      UNNotificationRequest *request = _notification;
      identifier.identifiers = @[request.identifier]; // 还需要设置delivered标志
#endif
    }
    [JPUSHService removeNotification:identifier];
    
    _notification = nil;
    alertMessage = @"取消上一个通知成功";
  } else {
    alertMessage = @"不存在上一个设置通知";
  }
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置"
                                                  message:alertMessage
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil, nil];
  [alert show];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  _backgroundView.frame = CGRectMake(_frame.origin.x, _frame.origin.y - 110,
                                     _frame.size.width, _frame.size.height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  _backgroundView.frame = _frame;
  return YES;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField.tag != 10) {
    return YES;
  }
  return YES;
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
