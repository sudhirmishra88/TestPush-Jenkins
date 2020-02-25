/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  MyApp
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <UserNotifications/UserNotifications.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    [self registerForRemoteNotifications];
    UNNotificationAction* stopAction = [UNNotificationAction
    actionWithIdentifier:@"STOP_ACTION"
    title:@"Stop"
    options:UNNotificationActionOptionForeground];
    
    UNNotificationAction* openAction = [UNNotificationAction
    actionWithIdentifier:@"Open_ACTION"
    title:@"Open"
    options:UNNotificationActionOptionForeground];
    
   UNNotificationCategory* generalCategory = [UNNotificationCategory
         categoryWithIdentifier:@"GENERAL"
         actions:@[stopAction,openAction]
         intentIdentifiers:@[]
         options:UNNotificationCategoryOptionCustomDismissAction];
     
    // Register the notification categories.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
     
    
    
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
- (void)registerForRemoteNotifications {
 UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
 [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge |     UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError * _Nullable error){
     if(!error){
         dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication] registerForRemoteNotifications];
         });
     }else{
         NSLog(@"%@",error.description);
     }
 }];
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  NSUInteger dataLength = deviceToken.length;
  if (dataLength == 0) {
    return;
  }
  const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
  NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i = 0; i < dataLength; ++i) {
    [hexString appendFormat:@"%02x", dataBuffer[i]];
  }
  NSLog(@"APN token:%@", hexString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"Error:%@",str);
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
     NSLog(@"Active");
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.sudhirmishra.ionic.push"];
   [shared setObject:@2 forKey:@"badgeCount"];
   // [shared synchronize];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
@end
