
//
//  AppDelegate.m
//  WeatherAlarm
//
//  Created by RYAN on 14/11/10.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "LocationHelper.h"
#import <AVFoundation/AVFoundation.h>

#define CoreDataFileName @"WeatherAlarm"
#define CoreDataStoreURL [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:CoreDataFileName]
#define kUserDefault_DeviceToken @"kUserDefault_DeviceToken"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate ()//<AVAudioPlayerDelegate>
@property (nonatomic, assign) SystemSoundID mySoundID;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadToken) name:@"updateLocation" object:nil];
    
    [[LocationHelper shareInstance] startLocate];
    
    if (IS_OS_8_OR_LATER){
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else{
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
    
    [self initCoreData];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"%@",userInfo);
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *message = [aps objectForKey:@"alert"];
    NSString *soundName = [aps objectForKey:@"sound"];
//    [self playSound:soundName];
    NSString *name = [soundName stringByDeletingPathExtension];
    NSString *exestr = [soundName pathExtension];
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:exestr];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer = player;
    [player play];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"天气闹钟" message:message  delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    AudioServicesRemoveSystemSoundCompletion(self.mySoundID);
    [self.audioPlayer stop];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *tokenString = [self stringWithDeviceToken:deviceToken];
    self.token = tokenString;
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"ERROR:%@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack

- (void)initCoreData{
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:CoreDataFileName withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    NSURL *storeURL = CoreDataStoreURL;
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSDictionary* options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    
    if ([persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path])
        {
            //When data model has changed, the old storage file will no longer compatible
//            [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
//            [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
        }
        else
        {
            //TODO show error to user
            abort();
        }
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainManagedContext = context;
    self.mainManagedContext.persistentStoreCoordinator = persistentStoreCoordinator;
    self.mainManagedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
}

- (NSString*)stringWithDeviceToken:(NSData*)deviceToken {
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}

- (void)uploadToken{
    NSString *currentToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault_DeviceToken];
    if ([currentToken isEqualToString:self.token]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:kUserDefault_DeviceToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@",self.token);
    }
    //TODO 上存至服务器
    
    NSString *urlString = @"http://1.weatheralarm.sinaapp.com/getToken.php";
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    client.parameterEncoding = AFJSONParameterEncoding;
    [client setDefaultHeader:@"Accept" value:@"text/json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.token forKey:@"token"];
    [params setObject:[LocationHelper shareInstance].locationID forKey:@"locationID"];
    
    
    [client getPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",responseStr);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"fail");
    }];

}
@end
