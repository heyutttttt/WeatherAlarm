//
//  AlarmHelper.m
//  WeatherAlarm
//
//  Created by RYAN on 14/12/1.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "AlarmHelper.h"
#import "AFHTTPClient.h"
#import "AppDelegate.h"

@implementation AlarmHelper

+ (instancetype)shareInstance{
    static AlarmHelper *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[AlarmHelper alloc] init];
        [_instance reloadDatas];
    });
    
    return _instance;
}

- (void)reloadDatas{
    self.alarmDatas = [self queryDatas];
}

- (NSMutableArray *)queryDatas{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
    [request setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"alarmID" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
    NSError *error = nil;
    NSMutableArray *mutableFetchResult = [[AppDelegateInstance.mainManagedContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (!mutableFetchResult) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
    
    return mutableFetchResult;
    
}

- (BOOL)save{
    NSError *error = nil;
    BOOL isSuccess = [AppDelegateInstance.mainManagedContext save:&error];
    if (!isSuccess) {
        //TODO
        NSLog(@"error:%@,%@",error,[error userInfo]);
    }
    return isSuccess;
    
}

- (void)updateAlarm:(Alarm *)alarm{
//    [AppDelegateInstance.mainManagedContext updatedObjects];
}

- (void)deleteAlarm:(Alarm *)alarm{
    [[AlarmHelper shareInstance] removeAlarmOfServer:alarm];
    [AppDelegateInstance.mainManagedContext deleteObject:alarm];
}

- (void)insertAlarm:(Alarm *)alarm{
    if ([self isExisted:alarm.alarmID]) {
        NSLog(@"已经存在了");
    }
    
    else{
        [AppDelegateInstance.mainManagedContext insertObject:alarm];
//        [self.alarmDatas addObject:alarm];
    }
}


- (BOOL)isExisted:(NSString *)alarmID{
    BOOL isExisted = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alarmID == %@",alarmID];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *results = [[AppDelegateInstance.mainManagedContext executeFetchRequest:request error:&error] mutableCopy];
    if (results == nil) {
//        TODO
        NSLog(@"Error :%@,%@",error,error.userInfo);
    }
    if (results.count != 0) {
        isExisted = YES;
    }
    
    return isExisted;
}

- (id)convertToCharString:(NSString *)text{
    if (text) {
        NSRange range = [text rangeOfString:@"等于"];
        if (range.location != NSNotFound) {
            NSString *targetText = [text substringFromIndex:2];
            targetText = [NSString stringWithFormat:@"=%@",targetText];
            return targetText;
        }
        
        range = [text rangeOfString:@"小于"];
        if (range.location != NSNotFound) {
            NSString *targetText = [text substringFromIndex:2];
            targetText = [NSString stringWithFormat:@"<%@",targetText];
            return targetText;
        }
        
        range = [text rangeOfString:@"大于"];
        if (range.location != NSNotFound) {
            NSString *targetText = [text substringFromIndex:2];
            targetText = [NSString stringWithFormat:@">%@",targetText];
            return targetText;
        }
    }
    return [NSNull null];
}

- (void)uploadAlarm:(Alarm *)alarm{
    NSString *alarmID = alarm.alarmID;
    NSNumber *alarmHour = alarm.alarmHour;
    NSNumber *alarmMin = alarm.alarmMin;
    NSString *alarmTemp = [self convertToCharString:alarm.alarmTemp];
    NSString *alarmSD = [self convertToCharString:alarm.alarmSD];
    NSString *alarmWS = [self convertToCharString:alarm.alarmWS];
    NSNumber *isOn = alarm.isOn;
    NSString *token = AppDelegateInstance.token;
    
    NSDictionary *parms = @{@"alarmID":alarmID,@"alarmHour":alarmHour,@"alarmMin":alarmMin,@"alarmTemp":alarmTemp,@"alarmSD":alarmSD,@"alarmWS":alarmWS,@"isOn":isOn,@"token":token};
    NSString *urlString = @"http://1.weatheralarm.sinaapp.com/insertAlarm.php";

    [self serveHandleWithPath:urlString WithParms:parms WithFailureText:@"insert失败"];
}

- (void)removeAlarmOfServer:(Alarm *)alarm{
    NSString *alarmID = alarm.alarmID;
    NSString *token = AppDelegateInstance.token;
    NSDictionary *params = @{@"alarmID":alarmID,@"token":token};
    NSString *urlString = @"http://1.weatheralarm.sinaapp.com/deleteAlarm.php";
    [self serveHandleWithPath:urlString WithParms:params WithFailureText:@"delete失败"];
}

- (void)resetAlarm:(Alarm *)alarm{
    NSString *alarmID = alarm.alarmID;
    NSNumber *alarmHour = alarm.alarmHour;
    NSNumber *alarmMin = alarm.alarmMin;
    NSString *alarmTemp = [self convertToCharString:alarm.alarmTemp];
    NSString *alarmSD = [self convertToCharString:alarm.alarmSD];
    NSString *alarmWS = [self convertToCharString:alarm.alarmWS];
    NSNumber *isOn = alarm.isOn;
    NSString *token = AppDelegateInstance.token;
    
    NSDictionary *parms = @{@"alarmID":alarmID,@"alarmHour":alarmHour,@"alarmMin":alarmMin,@"alarmTemp":alarmTemp,@"alarmSD":alarmSD,@"alarmWS":alarmWS,@"isOn":isOn,@"token":token};
    
    NSString *urlString = @"http://1.weatheralarm.sinaapp.com/resetAlarm.php";
    
    [self serveHandleWithPath:urlString WithParms:parms WithFailureText:@"修改失败"];
}

- (void)serveHandleWithPath:(NSString *)path WithParms:(NSDictionary *)dic WithFailureText:(NSString *)errorText{
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    client.parameterEncoding = AFJSONParameterEncoding;
    [client setDefaultHeader:@"Accept" value:@"text/json"];
    
    [client getPath:path parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",responseStr);
        NSRange range = [responseStr rangeOfString:@"delete successfully"];
        if (range.location != NSNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWhenDelete" object:@"删除成功"];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"insertalarm,error:%@",error);
        //TODO 显示传入不成功
        NSLog(@"%@",errorText);
    }];
    
}

@end
