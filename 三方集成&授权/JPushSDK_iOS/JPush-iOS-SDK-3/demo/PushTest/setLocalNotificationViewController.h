//
//  setLocalNotificationViewController.h
//  PushSDK
//
//  Created by 张 on 14-7-17.
//
//

#import <UIKit/UIKit.h>

@interface setLocalNotificationViewController
    : UIViewController<UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField *notificationBodyTextField;
@property(weak, nonatomic) IBOutlet UIDatePicker *notificationDatePicker;
@property(weak, nonatomic) IBOutlet UITextField *notificationButtonTextField;
@property(weak, nonatomic)
    IBOutlet UITextField *notificationIdentifierTextField;
@property(strong, nonatomic) IBOutlet UIView *backgroundView;
@property(weak, nonatomic) IBOutlet UITextField *notificationBadgeTextField;
- (IBAction)setNotification:(id)sender;
- (IBAction)clearAllNotification:(id)sender;
- (IBAction)clearLastNotification;
@end
