//
//  MainViewController.h
//  WeatherAlarm
//
//  Created by RYAN on 14/11/21.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *refreshIcon;

@property (strong, nonatomic) IBOutlet UIButton *refreshBtn;

@property (strong, nonatomic) IBOutlet UIButton *EditBtn;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet UIButton *AddBtn;

@property (strong, nonatomic) IBOutlet UILabel *tempLabel1;
@property (strong, nonatomic) IBOutlet UILabel *tempLabel2;
@property (strong, nonatomic) IBOutlet UILabel *tempLabel3;
@property (strong, nonatomic) IBOutlet UILabel *weekLabel1;
@property (strong, nonatomic) IBOutlet UILabel *weekLabel2;

@property (strong, nonatomic) IBOutlet UILabel *weekLabel3;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIcon1;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIcon2;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIcon3;
@property (strong, nonatomic) IBOutlet UILabel *TodayWeatherLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *minLabel;
@property (strong, nonatomic) IBOutlet UILabel *hourLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *rtTempLabel;
@property (strong, nonatomic) IBOutlet UIImageView *rtWeatherIcon;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
