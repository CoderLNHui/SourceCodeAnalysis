//
//  SetTagsViewController.h
//  PushSDK
//
//  Created by 张 on 14-7-17.
//
//

#import <UIKit/UIKit.h>

@interface SetTagsViewController : UIViewController
@property(weak, nonatomic) IBOutlet UITextField *tags1TextField;
@property(weak, nonatomic) IBOutlet UITextField *tags2TextField;
@property(weak, nonatomic) IBOutlet UITextField *tags3TextField;
@property(weak, nonatomic) IBOutlet UITextField *tags4TextField;
@property(weak, nonatomic) IBOutlet UITextField *aliasTextField;
@property(weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UITextView *callBackTextView;
@property(weak, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
- (IBAction)setTagsAlias:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)resetTags:(id)sender;
- (IBAction)resetAlias:(id)sender;
- (IBAction)TextField_DidEndOnExit:(id)sender;
- (IBAction)clearResult:(id)sender;
@end
