//
//  Weather.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/30.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weather : NSManagedObject

@property (nonatomic, retain) NSString * temperature;
@property (nonatomic, retain) NSString * weather;
@property (nonatomic, retain) NSDate * weatherDate;
@property (nonatomic, retain) NSString * week;
@property (nonatomic, retain) NSNumber * index;

@end
