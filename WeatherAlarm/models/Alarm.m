//
//  Alarm.m
//  WeatherAlarm
//
//  Created by RYAN on 14/12/2.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "Alarm.h"


@implementation Alarm

//@synthesize alarmID;
//@synthesize alarmMusic;
//@synthesize alarmTemp;
//@synthesize alarmSD;
//@synthesize alarmWS;
//@synthesize isOn;
//@synthesize alarmHour;
//@synthesize alarmMin;

@dynamic alarmID;
@dynamic alarmMusic;
@dynamic alarmTemp;
@dynamic alarmSD;
@dynamic alarmWS;
@dynamic isOn;
@dynamic alarmHour;
@dynamic alarmMin;

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        self.alarmMusic = @"默认";
    }
    
    return self;
}



//- (id)copyWithZone:(NSZone *)zone{
//    NSEntityDescription *description = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
//    Alarm *alarm = [[[self class] allocWithZone:zone] initWithEntity:description];
//    alarm.alarmID = [self.alarmID copy];
//    alarm.alarmHour = [self.alarmHour copy];
//    alarm.alarmMin = [self.alarmMin copy];
//    alarm.alarmMusic = [self.alarmMusic copy];
//    alarm.alarmSD = [self.alarmSD copy];
//    alarm.alarmTemp = [self.alarmTemp copy];
//    alarm.alarmWS = [self.alarmWS copy];
//    
//    return alarm;
//}

- (id)initWithHour:(NSInteger)hour WithMin:(NSInteger)min WithMusic:(NSString *)music WithSD:(NSString *)SD WithTemp:(NSString *)temp WithWS:(NSString *)WS{
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
    self = [super initWithEntity:desc insertIntoManagedObjectContext:AppDelegateInstance.mainManagedContext];
    if (self) {

        NSString *aID = [NSString stringWithFormat:@"%ld%ld",hour,min];
        self.alarmID = aID;
        self.alarmHour = [NSNumber numberWithInteger:hour];
        self.alarmMin = [NSNumber numberWithInteger:min];

        self.alarmSD = [SD mutableCopy];
        self.alarmTemp = [temp mutableCopy];
        self.alarmWS = [WS mutableCopy];
        if (music) {
            self.alarmMusic = [music mutableCopy];
        }
        else{
            self.alarmMusic = @"默认";
        }
    }
    
    return self;
}

- (void)resetIDWithHour:(NSInteger)hour
                WithMin:(NSInteger)min{
    NSString *string = [NSString stringWithFormat:@"%ld%ld",hour,min];
    self.alarmID = string;
}

@end
