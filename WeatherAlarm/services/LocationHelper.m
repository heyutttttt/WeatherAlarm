//
//  LocationHelper.m
//  WeatherAlarm
//
//  Created by RYAN on 14/11/12.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "LocationHelper.h"
#import "FMDatabase.h"

@implementation LocationHelper

+ (instancetype)shareInstance{
    
    static LocationHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LocationHelper alloc] init];
        
    });
    if (!_instance.locationManager) {
        
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        manager.delegate = _instance;
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        manager.distanceFilter = 100.0;
        
        _instance.locationManager = manager;
    }
    
    return _instance;
}

- (void)startLocate{
    
    if (![CLLocationManager locationServicesEnabled]) {
        //定位功能并没有打开
        //TODO
    }
    
    else{
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
            {//用户还未做出任何选择
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                break;
            }
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                //用户没有授权
            case kCLAuthorizationStatusAuthorized:
                //用户已授权
                break;
            default:
                break;
        }
        self.isLoading = YES;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopLocate{
    [self.locationManager stopUpdatingLocation];
}

- (void)updateLocationID{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"locationID" ofType:@"sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    BOOL res = [database open];
    if (res) {
        NSString *queryStr = [NSString stringWithFormat:@"select * from locations where name = \"%@\"",self.locationCity];
        FMResultSet *set = [database executeQuery:queryStr];
        while ([set next]) {
            NSString *IDStr = [set stringForColumn:@"cityID"];
            self.locationID = IDStr;
        }
    }
    
    [database close];
}

//去除有市的城市名，如广州市->广州
- (NSString *)simplifyCityName:(NSString *)cityName{
    NSRange range = [cityName rangeOfString:@"市"];
    if (range.location != NSNotFound) {
        cityName = [cityName substringToIndex:(cityName.length - 1)];
    }
    return cityName;
}

- (void)saveLocationInfo{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.locationCity forKey:@"city"];
    [user setObject:self.locationCountry forKey:@"country"];
    [user setObject:self.locationID forKey:@"cityID"];
    [user synchronize];
}

- (BOOL)loadLocationInfo{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.locationCity = [user objectForKey:@"city"];
    self.locationCountry = [user objectForKey:@"country"];
    self.locationID = [user objectForKey:@"cityID"];
    return (self.locationID && self.locationCountry && self.locationCity);
}

#pragma CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *currentLocation = [locations lastObject];
//    CLLocationCoordinate2D coor = currentLocation.coordinate;
//    NSLog(@"%f",coor.latitude);
//    NSLog(@"%f",coor.longitude);
    
    if (!self.geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
       
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.locationCountry = placemark.country;
            NSString *city = placemark.locality;
            self.locationCity = [self simplifyCityName:city];
            [self updateLocationID];
            [self saveLocationInfo];
            
            self.isLoading = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocation" object:nil];
        }
        
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if (error.code == kCLErrorDenied) {
        //TODO
        //获取位置失败
    }
    
    self.isLoading = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudWhenError" object:@"获取数据失败"];
}
@end
