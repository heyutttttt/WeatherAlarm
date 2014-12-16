//
//  WeatherTableViewCell.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/29.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Alarm;

@interface WeatherTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *alarmSwitch;
@property (strong, nonatomic) IBOutlet UILabel *AlarmTimeLabel;
@property (strong, nonatomic) Alarm *alarm;

@end
