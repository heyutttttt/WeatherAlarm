//
//  WeatherHelper.m
//  WeatherAlarm
//
//  Created by RYAN on 14/11/13.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "WeatherHelper.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "LocationHelper.h"

//#define WEATHER_API_LINK2 @"http://api.map.baidu.com/telematics/v3/weather"
//#define APP_KEY @"2a052ee71f53ef7264d8d731b3d82253"
//#define OUTPUT_TYPE @"json"

#define WEATHER_API_LINK @"http://m.weather.com.cn/atad/"//未来几日天气

#define REALTIME_WEATHER_LINK @"http://www.weather.com.cn/data/sk/"//实时

#define WEATHER_COUNT 3

@interface WeatherHelper()
@property (nonatomic, assign) BOOL rtWeatherShouldSave;
@property (nonatomic, assign) BOOL weatherShouldSave;

@end

@implementation WeatherHelper

+ (instancetype)shareInstance{
    static WeatherHelper *_instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _instance = [[WeatherHelper alloc] init];
    });
    
    return _instance;
}

- (void)getWeatherData{

//    NSString *URLTmp = @"http://61.4.185.48:81/g/";
//    NSString *URLTmp1 = [URLTmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //转码成UTF-8  否则可能会出现错误
//    URLTmp = URLTmp1;
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: URLTmp]];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success: %@", operation.responseString);
//        
//        NSString *requestTmp = [NSString stringWithString:operation.responseString];
//        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
//        //系统自带JSON解析
//        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Failure: %@", error);
////        [SVProgressHUD dismissWithError:@"提交失败，请重试"];
//    }];
//    [operation start];

//    NSString *urlString = @"http://61.4.185.48:81/g/";
//    NSString *encodeString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:encodeString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        if (!error){
//        
//            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSRange range = [dataString rangeOfString:@"var id="];
//            NSString *subString = [dataString substringFromIndex:(range.location + range.length)];
//            range = [subString rangeOfString:@";"];
//            NSString *l_id = [subString substringToIndex:range.location];
//            self.locationID = l_id;
//        }
//        [self reloadWeather];
//        [self reloadRealtimeWeather];
//    }];
//    
//    [task resume];
    
    if ([LocationHelper shareInstance].locationID) {
        
        self.isLoading = YES;
        [self reloadWeather];
        [self reloadRealtimeWeather];
    }
}

- (void)reloadRealtimeWeather{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@.html",REALTIME_WEATHER_LINK,[LocationHelper shareInstance].locationID];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    client.parameterEncoding = AFJSONParameterEncoding;
    [client setDefaultHeader:@"Accept" value:@"text/json"];
    
    [client getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (!dic) {
            //TODO
            return ;
        }
        
        else{
            NSDictionary *weatherDic = dic[@"weatherinfo"];
            [self insertRealtimeWeather:weatherDic];
        }
//        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        
//        NSLog(@"%@",responseStr);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"realtime :%@",error);
        self.isLoading = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudWhenError" object:@"获取实时天气数据失败"];
    }];
    
    
//    NSString *urlString = [NSString stringWithFormat:@"%@%@.html",REALTIME_WEATHER_LINK,self.locationID];
//    NSString *encodeString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:encodeString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        if (error || !dic) {
//            //TODO
//            return ;
//        }
//        
//        else{
//            NSDictionary *weatherDic = dic[@"weatherinfo"];
//            [self insertRealtimeWeather:weatherDic];
//        }
//    }];
//    
//    [task resume];
}

- (void)reloadWeather{
    NSString *urlString = [NSString stringWithFormat:@"%@%@.html",WEATHER_API_LINK,[LocationHelper shareInstance].locationID];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    client.parameterEncoding = AFJSONParameterEncoding;
    [client setDefaultHeader:@"Accept" value:@"text/json"];
    
    [client getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (!dic) {
            return ;
        }
        
        else{
            [self insertDatas:dic];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.isLoading = NO;
        NSLog(@"weather :%@",error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudWhenError" object:@"获取天气数据失败"];
    }];
    
    
//    NSString *urlString = [NSString stringWithFormat:@"%@%@.html",WEATHER_API_LINK,self.locationID];
//    NSString *encodeString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:encodeString];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLSession *session = [NSURLSession sharedSession];
//
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        if (error || !dic) {
//            NSLog(@"%@",error);
//        }
//        
//        else{
//            [self insertDatas:dic];
//        }
//        
//    }];
    
//    [task resume];
    
}

- (void)insertRealtimeWeather:(NSDictionary *)dic{
    NSArray *array = [self queryDatas:@"RealtimeWeather"];
    RealtimeWeather *weather = nil;
    if (!array || array.count == 0) {
        weather = (RealtimeWeather *)[NSEntityDescription insertNewObjectForEntityForName:@"RealtimeWeather" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
    }
    
    else{
        weather = [array lastObject];
    }
    NSNumber *temp = dic[@"temp"];
    [weather setTemp:[NSNumber numberWithInt:[temp intValue]]];
    [weather setIndex:[NSNumber numberWithInt:0]];
    self.rtWeather = weather;
    
    self.rtWeatherShouldSave = YES;
    [self saveToDB];
}


- (void)insertDatas:(NSDictionary *)dic{
    
    NSDictionary *weatherDic = dic[@"weatherinfo"];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy年MM月dd日"];
    
    NSMutableArray *mutableArray = [self queryDatas:@"Weather"];
    NSMutableArray *temArray = [NSMutableArray arrayWithCapacity:WEATHER_COUNT];
    
    for (int i=1; i <= WEATHER_COUNT; i++) {
        Weather *data = nil;
        if (!mutableArray || mutableArray.count == 0 ) {
            data = (Weather *)[NSEntityDescription insertNewObjectForEntityForName:@"Weather" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
        }
        
        else{
            data = [mutableArray objectAtIndex:(i - 1)];
        }
        [data setIndex:[NSNumber numberWithInt:i]];
//        [data setWeatherDate:[formatter dateFromString:weatherDic[@"date_y"]]];
        NSString *weekStr = [self getWeekAfterWeek:weatherDic[@"week"] days:(i - 1)];
        [data setWeek:weekStr];
//        [data setWeek:weatherDic[@"week"]];
        NSString *weather_key = [NSString stringWithFormat:@"weather%d",i];
        [data setWeather:weatherDic[weather_key]];
        NSString *temp_key = [NSString stringWithFormat:@"temp%d",i];
        [data setTemperature:weatherDic[temp_key]];
        
        [temArray addObject:data];
    }
    
    self.weatherDatas = [NSArray arrayWithArray:temArray];
    
    self.weatherShouldSave = YES;
    [self saveToDB];
}

- (void)saveToDB{
    if (self.rtWeatherShouldSave && self.weatherShouldSave) {
        NSError *error = nil;
        if (![AppDelegateInstance.mainManagedContext save:&error]) {
            //TODO save error
        }
        
        self.rtWeatherShouldSave = NO;
        self.weatherShouldSave = NO;
        self.isLoading = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATEVIEWS" object:nil];
    }
}

- (NSMutableArray *)queryDatas:(NSString *)entityName{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:AppDelegateInstance.mainManagedContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[AppDelegateInstance.mainManagedContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResult == nil)
    {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    return mutableFetchResult;
}

- (BOOL)getWeatherDataFromDB{
    NSArray *array = [self queryDatas:@"Weather"];
    NSArray *array2 = [self queryDatas:@"RealtimeWeather"];
    if (array.count != 0 && array2.count != 0) {
        self.weatherDatas = [NSArray arrayWithArray:array];
        self.rtWeather = [array2 firstObject];
//        for (int i=0; i<3; i++) {
//            Weather *data = [self.weatherDatas objectAtIndex:i];
//            NSLog(@"%d,%@",[data.index intValue],data.temperature);
//        }
        return YES;
    }
    
    else{
        return NO;
    }
}

- (NSString *)getWeekAfterWeek:(NSString *)week days:(int)days{
    NSArray *weeks = [NSArray arrayWithObjects:@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日", nil];
    NSInteger index = [weeks indexOfObject:week];
    index = (index + days)%7;
    NSString *weekStr = [weeks objectAtIndex:index];
    
    return weekStr;
}

@end
