//
//  NotificationService.m
//  NotificationServiceTest
//
//  Created by jpush on 16/7/26.
//
//

#import "NotificationService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
  self.contentHandler = contentHandler;
  self.bestAttemptContent = [request.content mutableCopy];
  self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [NotificationService]", self.bestAttemptContent.title];
  
  NSURLSession * session = [NSURLSession sharedSession];
  NSString * attachmentPath = self.bestAttemptContent.userInfo[@"my-attachment"];
  //if exist
  if (attachmentPath && [attachmentPath hasSuffix:@"png"]) {
    //download
    NSURLSessionTask * task = [session dataTaskWithURL:[NSURL URLWithString:attachmentPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      if (data) {
        NSString * localPath = [NSString stringWithFormat:@"%@/myAttachment.png", NSTemporaryDirectory()];
        if ([data writeToFile:localPath atomically:YES]) {
          UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"myAttachment" URL:[NSURL fileURLWithPath:localPath] options:nil error:nil];
          self.bestAttemptContent.attachments = @[attachment];
        }
      }
      self.contentHandler(self.bestAttemptContent);
    }];
    [task resume];
  }else{
    self.contentHandler(self.bestAttemptContent);
  }
}

- (void)serviceExtensionTimeWillExpire {
  self.contentHandler(self.bestAttemptContent);
}

@end
#endif
