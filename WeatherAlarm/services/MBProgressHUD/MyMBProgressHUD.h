//
//  MyMBProgressHUD.h
//  WeatherAlarm
//
//  Created by RYAN on 14/12/7.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface MyMBProgressHUD : NSObject <MBProgressHUDDelegate>

@property (nonatomic, assign) BOOL isPresented;
//@property (nonatomic, strong) MBProgressHUD *hud;

+ (instancetype)shareInstance;
- (void)showHudOnView:(UIView *)view WithText:(NSString *)text;

@end
