//
//  NSDictionary+Safe.m
//  Ekeo2
//
//  Created by Roger on 13-8-19.
//  Copyright (c) 2013年 Ekeo. All rights reserved.
//

#import "NSDictionary+Safe.h"

@implementation NSDictionary (Safe)

- (BOOL)hasObjectForKey:(NSString*)key
{
    return [self safeObjectForKey:key] != nil;
}

- (id)safeObjectForKey:(NSString*)key
{
    id result = [self objectForKey:key];
    return result != nil && result != [NSNull null]? result : nil;
}

- (NSString*)safeStringForKey:(NSString*)key
{
    id result = [self objectForKey:key];
    return result != nil && result != [NSNull null]? result : @"";
}

- (NSNumber*)safeNumberForKey:(NSString*)key
{
    id result = [self objectForKey:key];
    return result != nil && result != [NSNull null]? result : [NSNumber numberWithInt:0];
}

- (int)safeIntForKey:(NSString*)key
{
    return [[self safeNumberForKey:key] intValue];
}

- (long long)safeLongLongForKey:(NSString*)key
{
    return [[self safeNumberForKey:key] longLongValue];
}

- (float)safeFloatForKey:(NSString*)key
{
    return [[self safeNumberForKey:key] floatValue];
}

- (double)safeDoubleForKey:(NSString*)key
{
    return [[self safeNumberForKey:key] doubleValue];
}

@end
