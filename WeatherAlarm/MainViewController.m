//
//  MainViewController.m
//  WeatherAlarm
//
//  Created by RYAN on 14/11/21.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "MainViewController.h"
#import "WeatherHelper.h"
#import "WeatherTableViewCell.h"
#import "AlarmViewController.h"
#import "AlarmHelper.h"
#import "LocationHelper.h"
#import "MyMBProgressHUD.h"


//#define BackgroundColor [UIColor colorWithRed:222/255.0 green:190/255.0 blue:65/255.0 alpha:1.0]
#define CellReuseIdentifier @"CellReuseIdentifier"

@interface MainViewController ()<AlarmViewControllerDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *weekdays;
@property (nonatomic, strong) AlarmViewController *alarmSettingVC;

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) BOOL isLocationLoading;
@property (nonatomic, assign) BOOL isWeatherLoading;

@end

@implementation MainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATEVIEWS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateLocation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowHudWhenError" object:nil];
    [_timer invalidate];
}

- (void)startAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1.0;
    animation.repeatCount = MAXFLOAT;
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2*M_PI];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    self.isAnimating = YES;
    [self.refreshIcon.layer addAnimation:animation forKey:@"refresh"];
}

- (void)stopAnimation{
    self.isAnimating = NO;
    [self.refreshIcon.layer removeAnimationForKey:@"refresh"];
}

- (IBAction)refreshData:(id)sender {
    if (!self.isAnimating) {
        [self startAnimation];
        [[WeatherHelper shareInstance] getWeatherData];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    BOOL loading = [change[@"new"] boolValue];
    NSString *contextStr = (__bridge NSString*)context;
    if ([contextStr isEqualToString:@"LocationHelper"]) {
        self.isLocationLoading = loading;
    }
    else if ([contextStr isEqualToString:@"WeatherHelper"]){
        self.isWeatherLoading = loading;
    }
    
    if (!self.isLocationLoading && !self.isWeatherLoading) {
        [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:3.0];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
//     Do any additional setup after loading the view.
    LocationHelper *locationHelper = [LocationHelper shareInstance];
    [locationHelper addObserver:self forKeyPath:@"isLoading" options:(NSKeyValueObservingOptionNew) context:@"LocationHelper"];
    WeatherHelper *weatherHelper = [WeatherHelper shareInstance];
    [weatherHelper addObserver:self forKeyPath:@"isLoading" options:NSKeyValueObservingOptionNew context:@"WeatherHelper"];
    
    [self startAnimation];
    
    self.weekdays = [NSArray arrayWithObjects:@"星期天",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews) name:@"UPDATEVIEWS" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationLabel) name:@"updateLocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHudWhenError:) name:@"ShowHudWhenError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAlarmDataWhenFinishDelete:) name:@"reloadWhenDelete" object:nil];
    
    [self updateTimeLabels];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeLabels) userInfo:nil repeats:YES];
    
    if ([[WeatherHelper shareInstance] getWeatherDataFromDB]) {
        [self updateViews];
    }
    
    if ([[LocationHelper shareInstance] loadLocationInfo]) {
        [self updateLocationLabel];
    }
    
    [self.myTableView setBackgroundColor:[UIColor clearColor]];
    [self.myTableView registerNib:[UINib nibWithNibName:@"WeatherTableViewCell" bundle:nil] forCellReuseIdentifier:CellReuseIdentifier];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.datas = [AlarmHelper shareInstance].alarmDatas;
    
    [self.myTableView setFrame:CGRectMake(self.myTableView.frame.origin.x, self.myTableView.frame.origin.y, self.myTableView.frame.size.width, self.view.frame.size.height - self.myTableView.frame.origin.y)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHudWhenError:(NSNotification *)notification{
    NSString *object = [notification object];
    [[MyMBProgressHUD shareInstance] showHudOnView:self.view WithText:object];
}

- (void)updateLocationLabel{
    [[WeatherHelper shareInstance] getWeatherData];
    LocationHelper *helper = [LocationHelper shareInstance];
    NSString *text = [NSString stringWithFormat:@"%@,%@",helper.locationCity,helper.locationCountry];
    [self.locationLabel setText:text];
}

- (void)updateTimeLabels{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSYearCalendarUnit|NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
    
    NSInteger seconds = dateComponents.second;
    NSString *secondStr = (seconds < 10) ? [NSString stringWithFormat:@"0%ld",seconds] : [NSString stringWithFormat:@"%ld",seconds];
    [self.secondLabel setText:secondStr];
    
    NSInteger mins = dateComponents.minute;
    NSString *minStr = (mins < 10) ? [NSString stringWithFormat:@"0%ld",mins] : [NSString stringWithFormat:@"%ld",mins];
    [self.minLabel setText:minStr];
    

    NSInteger hours = dateComponents.hour;
    NSString *hourStr = (hours < 10) ? [NSString stringWithFormat:@"0%ld",hours] : [NSString stringWithFormat:@"%ld",hours];
    [self.hourLabel setText:hourStr];
    
    NSString *weekDayStr = [self.weekdays objectAtIndex:(dateComponents.weekday - 1)];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %ld.%ld",weekDayStr,dateComponents.month,dateComponents.day];
    [self.dateLabel setText:dateStr];
    
}

- (void)updateViews{

    NSArray *datas = [WeatherHelper shareInstance].weatherDatas;
    
    RealtimeWeather *weather = [WeatherHelper shareInstance].rtWeather;
    [self.rtTempLabel setText:[NSString stringWithFormat:@"%@℃",weather.temp ]];
    
    if (datas && datas.count != 0) {
        Weather *data = [datas objectAtIndex:0];
        [self.tempLabel1 setText:data.temperature];
        [self.weekLabel1 setText:data.week];
        NSString *iconName = [self getIconNameWithWeather:data.weather];
        [self.weatherIcon1 setImage:[UIImage imageNamed:iconName]];
        [self.TodayWeatherLabel setText:data.weather];
        [self.rtWeatherIcon setImage:[UIImage imageNamed:iconName]];
        
        data = [datas objectAtIndex:1];
        [self.tempLabel2 setText:data.temperature];
        [self.weekLabel2 setText:data.week];
        iconName = [self getIconNameWithWeather:data.weather];
        [self.weatherIcon2 setImage:[UIImage imageNamed:iconName]];
        
        data = [datas objectAtIndex:2];
        [self.tempLabel3 setText:data.temperature];
        [self.weekLabel3 setText:data.week];
        iconName = [self getIconNameWithWeather:data.weather];
        [self.weatherIcon3 setImage:[UIImage imageNamed:iconName]];
        
       
    }
    
}

- (NSString *)getIconNameWithWeather:(NSString *)weather{
    NSRange range = [weather rangeOfString:@"雪"];
    if (range.location != NSNotFound) {
        return @"snowy";
    }
    
    else{
        range = [weather rangeOfString:@"雷"];
        if (range.location != NSNotFound){
            return @"thunder";
        }
        
        else{
            range = [weather rangeOfString:@"雾"];
            if (range.location != NSNotFound) {
                return @"foggy";
            }
            
            else{
                range = [weather rangeOfString:@"雨"];
                if (range.location != NSNotFound) {
                    return @"rainy";
                }
                
                else{
                    range = [weather rangeOfString:@"云"];
                    if (range.location != NSNotFound) {
                        return @"cloudy";
                    }
                    
                    else{
                        return @"sunny";
                    }
                }
            }
        }
    }
}
- (IBAction)setTableViewEditMode:(id)sender {
    if (self.datas.count != 0){
        self.AddBtn.userInteractionEnabled = NO;
        [self.myTableView setEditing:YES animated:YES];
    }
}

- (IBAction)finishEdit:(id)sender {
    if (self.myTableView.editing) {
        self.AddBtn.userInteractionEnabled = YES;
        [self.myTableView setEditing:NO animated:YES];

    }
}

- (IBAction)showAlarmSettingVC:(id)sender {
    if (self.alarmSettingVC == nil) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AlarmViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"AlarmViewController"];
        
        vc.delegate = self;
        self.alarmSettingVC = vc;
        [self.view addSubview:self.alarmSettingVC.view];
    }
    
//    self.alarmSettingVC.alarm = nil;

    [self.alarmSettingVC showWithAlarm:nil];
}

- (void)reloadAlarmDataWhenFinishDelete:(NSNotification *)notification{
    [self finishEdit:nil];
    [self reloadAlarmData];
    [self showHudWhenError:notification];
}

#pragma tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.datas count] == 0) {
        return 1;
    }
    
    else{
        return [self.datas count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];

    
    if ([self.datas count] == 0) {
        
        [cell.alarmSwitch setHidden:YES];
        [cell.AlarmTimeLabel setText:@"没有闹钟"];
    }
    
    else{

        Alarm *alarm = [self.datas objectAtIndex:indexPath.row];
        cell.alarm = alarm;
        [cell.alarmSwitch setHidden:NO];        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.datas.count != 0) {
        
        Alarm *alarm = [self.datas objectAtIndex:indexPath.row];
        
        if (self.alarmSettingVC == nil) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AlarmViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"AlarmViewController"];
            vc.delegate = self;
            self.alarmSettingVC = vc;
            [self.view addSubview:self.alarmSettingVC.view];
        }
        
        [self.alarmSettingVC showWithAlarm:alarm];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Alarm *alarm = [self.datas objectAtIndex:indexPath.row];
    [[AlarmHelper shareInstance] deleteAlarm:alarm];
    [[AlarmHelper shareInstance] save];
}

#pragma AlarmViewControllerDelegate

- (void)reloadAlarmData{
    [[AlarmHelper shareInstance] reloadDatas];
    self.datas = [AlarmHelper shareInstance].alarmDatas;
    [self.myTableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
