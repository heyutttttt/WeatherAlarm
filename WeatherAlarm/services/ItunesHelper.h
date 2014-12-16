//
//  ItunesHelper.h
//  WeatherAlarm
//
//  Created by RYAN on 14/12/7.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItunesHelper : NSObject

+ (instancetype)shareInstance;
- (NSArray *)getCAFMusicFromItunes;

@end
