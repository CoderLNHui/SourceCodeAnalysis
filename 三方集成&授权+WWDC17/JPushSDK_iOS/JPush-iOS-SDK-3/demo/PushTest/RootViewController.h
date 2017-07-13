//
//  IndexViewController.h
//  PushSDK
//
//  Created by 张 on 14-7-16.
//
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
  NSMutableArray *_messageContents;
  int _messageCount;
  int _notificationCount;
}
@property (weak, nonatomic) IBOutlet UILabel *appKeyLabel;
@property(weak, nonatomic) IBOutlet UILabel *netWorkStateLabel;
@property(weak, nonatomic) IBOutlet UILabel *deviceTokenValueLabel;
@property(weak, nonatomic) IBOutlet UILabel *UDIDValueLabel;
@property(weak, nonatomic) IBOutlet UILabel *messageCountLabel;
@property(weak, nonatomic) IBOutlet UITextView *messageContentView;
@property(weak, nonatomic) IBOutlet UILabel *registrationValueLabel;
@property(weak, nonatomic) IBOutlet UIButton *cleanMessageButton;
@property(weak, nonatomic) IBOutlet UILabel *notificationCountLabel;
- (void)addNotificationCount;
- (IBAction)cleanMessage:(id)sender;
@end
