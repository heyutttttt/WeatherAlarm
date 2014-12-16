//
//  AlarmViewController.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/30.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmHelper.h"

@protocol AlarmViewControllerDelegate <NSObject>

- (void)reloadAlarmData;

@end

@interface AlarmViewController : UIViewController

@property (nonatomic, strong) Alarm *alarm;
@property (nonatomic, assign) id<AlarmViewControllerDelegate> delegate;

- (void)showWithAlarm:(Alarm *)newAlarm;
- (void)hide;

@end
