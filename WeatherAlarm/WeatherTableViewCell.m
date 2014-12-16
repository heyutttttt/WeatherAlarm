//
//  WeatherTableViewCell.m
//  WeatherAlarm
//
//  Created by RYAN on 14/11/29.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "WeatherTableViewCell.h"
#import "AlarmHelper.h"

#define ON_BackgroundColor [UIColor colorWithRed:247/255.0 green:205/255.0 blue:45/255.0 alpha:1.0]
#define OFF_BackgroundColor [UIColor whiteColor]

@implementation WeatherTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeSwitch:(UISwitch *)sender{
    if (sender.isOn) {
        self.contentView.backgroundColor = ON_BackgroundColor;
    }
    else{
        self.contentView.backgroundColor  = OFF_BackgroundColor;
    }
    
    self.alarm.isOn = [NSNumber numberWithBool:sender.isOn];
    [[AlarmHelper shareInstance] save];
    [[AlarmHelper shareInstance] resetAlarm:self.alarm];
}

- (void)setAlarm:(Alarm *)newAlarm{
    _alarm = newAlarm;
    
    BOOL isOn = [_alarm.isOn boolValue];
//    [self.alarmSwitch setOn:isOn];s
    self.alarmSwitch.on = isOn;
    self.contentView.backgroundColor = ((isOn) ? ON_BackgroundColor : OFF_BackgroundColor);
    NSString *text;
    if ([self.alarm.alarmMin integerValue]< 10) {
        text = [NSString stringWithFormat:@"%@:0%@",self.alarm.alarmHour,self.alarm.alarmMin];
    }
    else{
        text = [NSString stringWithFormat:@"%@:%@",self.alarm.alarmHour,self.alarm.alarmMin];
    }
    
    [self.AlarmTimeLabel setText:text];
    
}
@end
