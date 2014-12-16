//
//  Alarm.h
//  WeatherAlarm
//
//  Created by RYAN on 14/12/2.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface Alarm : NSManagedObject <NSCopying>

@property (nonatomic, retain) NSString * alarmID;
@property (nonatomic, retain) NSString * alarmMusic;
@property (nonatomic, retain) NSString * alarmTemp;
@property (nonatomic, retain) NSString * alarmSD;
@property (nonatomic, retain) NSString * alarmWS;
@property (nonatomic, retain) NSNumber * isOn;
@property (nonatomic, retain) NSNumber * alarmHour;
@property (nonatomic, retain) NSNumber * alarmMin;

- (id)initWithHour:(NSInteger)hour WithMin:(NSInteger)min WithMusic:(NSString *)music WithSD:(NSString *)SD WithTemp:(NSString *)temp WithWS:(NSString *)WS;

//- (id)copy;
- (void)resetIDWithHour:(NSInteger)hour
                WithMin:(NSInteger)min;
@end
