//
//  RealtimeWeather.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/30.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RealtimeWeather : NSManagedObject

@property (nonatomic, retain) NSString * weather;
@property (nonatomic, retain) NSNumber * temp;
@property (nonatomic, retain) NSString * wd;
@property (nonatomic, retain) NSNumber * ws;
@property (nonatomic, retain) NSNumber * sd;
@property (nonatomic, retain) NSNumber * wse;
@property (nonatomic, retain) NSNumber * index;

@end
