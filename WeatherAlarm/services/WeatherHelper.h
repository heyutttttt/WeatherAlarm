//
//  WeatherHelper.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/13.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weather.h"
#import "RealtimeWeather.h"

@interface WeatherHelper : NSObject

@property (nonatomic, strong) NSString *locationID;
@property (nonatomic, strong) NSArray *weatherDatas;
@property (nonatomic, strong) RealtimeWeather *rtWeather;
@property (nonatomic, assign) BOOL isLoading;

+ (instancetype)shareInstance;
- (void)getWeatherData;
- (BOOL)getWeatherDataFromDB;

@end
