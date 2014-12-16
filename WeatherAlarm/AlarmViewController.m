//
//  AlarmViewController.m
//  WeatherAlarm
//
//  Created by RYAN on 14/11/30.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "AlarmViewController.h"
#import "SettingPickerView.h"
#import "AppDelegate.h"

#define CANCELBTNTAG 1
#define SUREBTNTAG 2
#define BackgroundColor [UIColor colorWithRed:247/255.0 green:205/255.0 blue:45/255.0 alpha:1.0]

@interface AlarmViewController ()<UIPickerViewDataSource, UIPickerViewDelegate,UITableViewDataSource, UITableViewDelegate,SettingPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

@property (strong, nonatomic) IBOutlet UIPickerView *timePicker;

@property (strong, nonatomic) NSArray *hours;
@property (strong, nonatomic) NSArray *mins;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *settings;

@property (nonatomic, strong) SettingPickerView *settingPV;

@property (nonatomic, assign) NSInteger alarmHour;
@property (nonatomic, assign) NSInteger alarmMin;

@property (nonatomic, strong) Alarm *currentAlarm;

@end

@implementation AlarmViewController


//- (id)init{
//    self = [super init];
//    if (self) {
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cancelBtn.tag = CANCELBTNTAG;
    self.sureBtn.tag = SUREBTNTAG;
    self.timePicker.showsSelectionIndicator = YES;
    [self initDatas];
    
    NSArray *array = [NSArray arrayWithObjects:@"音乐",@"温度",@"相对湿度",@"风力", nil];
    self.settings = [NSArray arrayWithArray:array];
//    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
}

- (void)initDatas{
    NSMutableArray *minsArray = [NSMutableArray arrayWithCapacity:60];
    for (int i = 0; i<60; i++) {
        NSString *min = (i<10) ? [NSString stringWithFormat:@"0%d",i] : [NSString stringWithFormat:@"%d",i];
        [minsArray addObject:min];
    }
    
    NSMutableArray *hoursArray = [NSMutableArray arrayWithCapacity:24];
    for (int i = 0; i<24; i++) {
        NSString *hour = (i<10) ? [NSString stringWithFormat:@"0%d",i] : [NSString stringWithFormat:@"%d",i];
        [hoursArray addObject:hour];
    }
    
    self.hours = [NSArray arrayWithArray:hoursArray];
    self.mins = [NSArray arrayWithArray:minsArray];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    [self.view setFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show{
    [UIView animateWithDuration:0.3f animations:^{
       
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showWithAlarm:(Alarm *)newAlarm{
    
    self.alarm = newAlarm;
    self.currentAlarm = self.alarm;
    if (!self.alarm) {
//        self.currentAlarm = [self.alarm copy];
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
        Alarm *alarm = [[Alarm alloc] initWithEntity:description insertIntoManagedObjectContext:AppDelegateInstance.mainManagedContext];
        self.currentAlarm = alarm;
        
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSYearCalendarUnit|NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
        self.alarmHour = dateComponents.hour;
        self.alarmMin = dateComponents.minute;
        
    }
    
    else{
        //TODO
        NSLog(@"初始化闹钟时间");
        self.alarmHour = [self.alarm.alarmHour integerValue];
        self.alarmMin = [self.alarm.alarmMin integerValue];
        
    }
    [self.myTableView reloadData];
    [self show];
    
    [self.timePicker selectRow:self.alarmHour inComponent:0 animated:NO];
    [self.timePicker selectRow:self.alarmMin inComponent:1 animated:NO];
}

- (IBAction)clickToHide:(id)sender {
    
    UIButton *btn = sender;
    if (btn.tag == CANCELBTNTAG) {
        
        [self hide];
    }
    
    else{
        
        NSString *alarmID = [NSString stringWithFormat:@"%ld%ld",self.alarmHour,self.alarmMin];
        
        if ([self.alarm.alarmID isEqualToString:alarmID] || self.alarm == nil) {
            //闹钟时间未变 或 新建一个
            BOOL shouldEdit = NO;
            if (!self.alarm) {
                Alarm *alarm = [[Alarm alloc] initWithHour:self.alarmHour WithMin:self.alarmMin WithMusic:self.currentAlarm.alarmMusic WithSD:self.currentAlarm.alarmSD WithTemp:self.currentAlarm.alarmTemp WithWS:self.currentAlarm.alarmWS];
                alarm.isOn = [NSNumber numberWithBool:YES];
                self.alarm = alarm;
//                [[AlarmHelper shareInstance] insertAlarm:alarm];
                
            }
            
            else{
                shouldEdit = YES;
                self.alarm.alarmMusic = self.currentAlarm.alarmMusic;
                self.alarm.alarmSD = self.currentAlarm.alarmSD;
                self.alarm.alarmTemp = self.currentAlarm.alarmTemp;
                self.alarm.alarmWS = self.currentAlarm.alarmWS;
                
            }
            

            [self hide];
            [[AlarmHelper shareInstance] save];
            if (shouldEdit) {
                [[AlarmHelper shareInstance] resetAlarm:self.alarm];
            }
            else{
                [[AlarmHelper shareInstance] uploadAlarm:self.alarm];
            }
            [self.delegate reloadAlarmData];
        }
        
        else{
            //闹钟时间改变
            if ([[AlarmHelper shareInstance] isExisted:alarmID]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前时间已被设置过" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            else{
                //没有重复
                self.currentAlarm.alarmHour = [NSNumber numberWithInteger:self.alarmHour];
                self.currentAlarm.alarmMin = [NSNumber numberWithInteger:self.alarmMin];
                [[AlarmHelper shareInstance] resetAlarm:self.currentAlarm];
                
                
                [self.alarm resetIDWithHour:self.alarmHour WithMin:self.alarmMin];
                
                self.alarm.alarmHour = [NSNumber numberWithInteger:self.alarmHour];
                self.alarm.alarmMin = [NSNumber numberWithInteger:self.alarmMin];
                self.alarm.alarmMusic = self.currentAlarm.alarmMusic;
                self.alarm.alarmSD = self.currentAlarm.alarmSD;
                self.alarm.alarmTemp = self.currentAlarm.alarmTemp;
                self.alarm.alarmWS = self.currentAlarm.alarmWS;
                

                [self hide];
                [[AlarmHelper shareInstance] save];
                [self.delegate reloadAlarmData];
            }
        }
    }
    
}

- (void)hide{
    if (self.currentAlarm != self.alarm) {
        [AppDelegateInstance.mainManagedContext deleteObject:self.currentAlarm];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.view setFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma pickerview
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 1000;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return [self.hours objectAtIndex:(row%24)];
    }
    else{
        return [self.mins objectAtIndex:(row%60)];
    }
}

#pragma tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.settings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:BackgroundColor];
    }
    
    [cell.textLabel setText:[self.settings objectAtIndex:indexPath.row]];
    
    if (self.currentAlarm != nil) {
        switch (indexPath.row) {
            case 0:{
                [cell.detailTextLabel setText:self.currentAlarm.alarmMusic];
                break;
            }
            case 1:
                [cell.detailTextLabel setText:self.currentAlarm.alarmTemp];
                break;
            case 2:
                [cell.detailTextLabel setText:self.currentAlarm.alarmSD];
                break;
            case 3:
                [cell.detailTextLabel setText:self.currentAlarm.alarmWS];
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0) {
        if (!self.settingPV) {
            SettingPickerView *v = [[SettingPickerView alloc] init];
            v.delegate = self;
            self.settingPV = v;
        }
        PickerType type;
        switch (indexPath.row) {
            case 0:
                type = MusicType;
                break;
            case 1:
                type = TempType;
                break;
            case 2:
                type = SDType;
                break;
            case 3:
                type = WSType;
                break;
                
            default:
                break;
        }
        self.settingPV.type = type;
        self.settingPV.isOneComponent = ((type == MusicType) ? YES : NO);
        
        [self.settingPV setAlarm:self.currentAlarm];
        
        [self.settingPV.pickerView reloadAllComponents];
        [self.view addSubview:self.settingPV];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0){
        self.alarmHour = row%24;
    }
    
    else{
        self.alarmMin = row%60;
    }
    
}

#pragma SettingPickerViewDelegate
- (void)reloadSettingDatas{
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
