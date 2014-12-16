//
//  MyMBProgressHUD.m
//  WeatherAlarm
//
//  Created by RYAN on 14/12/7.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "MyMBProgressHUD.h"

@implementation MyMBProgressHUD

+ (instancetype)shareInstance{
    static MyMBProgressHUD *instance;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [[MyMBProgressHUD alloc] init];
    });
    
    return instance;
}

- (void)showHudOnView:(UIView *)view WithText:(NSString *)text{
    if (!self.isPresented) {
        self.isPresented = YES;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.delegate = self;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = text;
        hud.margin = 10.f;
        hud.yOffset = 0;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
    }
}

#pragma MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud{
    [hud removeFromSuperview];
    hud = nil;
    self.isPresented = NO;
}

@end
