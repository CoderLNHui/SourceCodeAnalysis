//
//  NotificationService.h
//  NotificationServiceTest
//
//  Created by jpush-macmini on 16/7/26.
//
//
#import <Foundation/Foundation.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>

@interface NotificationService : UNNotificationServiceExtension

@end

#endif
