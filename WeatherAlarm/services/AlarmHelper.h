//
//  AlarmHelper.h
//  WeatherAlarm
//
//  Created by RYAN on 14/12/1.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alarm.h"

@interface AlarmHelper : NSObject

@property (nonatomic, strong) NSMutableArray *alarmDatas;

+ (instancetype)shareInstance;

- (void)reloadDatas;

- (BOOL)save;

- (void)insertAlarm:(Alarm *)alarm;

- (BOOL)isExisted:(NSString *)alarmID;

- (void)updateAlarm:(Alarm *)alarm;

- (void)deleteAlarm:(Alarm *)alarm;

//
- (void)uploadAlarm:(Alarm *)alarm;//传上服务器
- (void)resetAlarm:(Alarm *)alarm;

@end
