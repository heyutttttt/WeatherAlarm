//
//  LocationHelper.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/12.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationHelper : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) NSString *locationID;
@property (strong, nonatomic) NSString *locationCity;
@property (strong, nonatomic) NSString *locationCountry;
@property (nonatomic, assign) BOOL isLoading;

+ (instancetype)shareInstance;

- (BOOL)loadLocationInfo;
- (void)startLocate;
- (void)stopLocate;

@end
