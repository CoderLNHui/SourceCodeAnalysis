//
//  SendBadgeViewController.h
//  PushSDK
//
//  Created by 张庆贺 on 14-7-31.
//
//

#import <UIKit/UIKit.h>

@interface SendBadgeViewController : UIViewController<UITextFieldDelegate>

@property(strong, nonatomic) IBOutlet UITextField *sendBadgeText;
@property(strong, nonatomic) IBOutlet UIButton *sendBadgeButton;
@property(strong, nonatomic) IBOutlet UIView *backgroundView;

@end
