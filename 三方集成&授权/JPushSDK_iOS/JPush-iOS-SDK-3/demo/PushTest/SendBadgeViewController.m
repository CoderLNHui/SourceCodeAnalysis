//
//  SendBadgeViewController.m
//  PushSDK
//
//  Created by 张庆贺 on 14-7-31.
//
//

#import "SendBadgeViewController.h"
#import "JPUSHService.h"

@interface SendBadgeViewController () {
  CGRect _frame;
}
@end

@implementation SendBadgeViewController

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

  [_sendBadgeButton addTarget:self
                       action:@selector(onClick)
             forControlEvents:UIControlEventTouchUpInside];

  // Do any additional setup after loading the view from its nib.
}

- (IBAction)View_TouchDown:(id)sender {
  // 发送resignFirstResponder.
  [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                             to:nil
                                           from:nil
                                       forEvent:nil];
  _backgroundView.frame = _frame;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)onClick {
  NSString *stringBadge = _sendBadgeText.text;
  int value = [stringBadge intValue];

  [JPUSHService setBadge:value];
  NSLog(@"send badge:%d to jpush server", value);
}
@end
