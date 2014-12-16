//
//  ItunesHelper.m
//  WeatherAlarm
//
//  Created by RYAN on 14/12/7.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "ItunesHelper.h"

@implementation ItunesHelper

+ (instancetype)shareInstance{
    static ItunesHelper *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[ItunesHelper alloc] init];
    });
    return instance;
}

- (NSArray *)getCAFMusicFromItunes{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"默认"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    for (NSString *file in fileList)
    {
        if ([[file pathExtension] isEqualToString:@"caf"]) {
            NSLog(@"%@",file);
            NSString *name = [file substringToIndex:(file.length - 1 - 3)];
            [array addObject:name];
            
        }
    }
    
    return array;
}

@end
