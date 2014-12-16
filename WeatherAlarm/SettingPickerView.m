//
//  SettingPickerView.m
//  WeatherAlarm
//
//  Created by RYAN on 14/12/1.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import "SettingPickerView.h"
#import "ItunesHelper.h"

#define PickerView_Height 216
#define ButtonSizeWidth 60
#define ButtonSizeHeight 40


@interface SettingPickerView ()

@property (nonatomic, strong) NSArray *firstComponentDatas;
@property (nonatomic, strong) NSArray *musicDatas;

@property (nonatomic, strong) NSArray *wsDatas;
//@property (nonatomic, strong) NSArray *wseDatas;
@property (nonatomic, strong) NSArray *tempDatas;
@property (nonatomic, strong) NSArray *sdDatas;

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) NSString *compareString;
@property (nonatomic, strong) NSString *contentString;

//@property (nonatomic, strong) Alarm *currentAlarm;

@end

@implementation SettingPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init{
    self = [super init];
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        
        [self initViews];
        [self initDatas];
        
    }
    return self;
}

- (void)initViews{
    CGRect frame = [UIScreen mainScreen].bounds;
    [self setFrame:frame];
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.size.height - PickerView_Height, frame.size.width, PickerView_Height)];
//    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self addSubview:self.pickerView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setFrame:CGRectMake(0, self.pickerView.frame.origin.y - ButtonSizeHeight, ButtonSizeWidth, ButtonSizeHeight)];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelBtn];
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sureBtn setFrame:CGRectMake(self.pickerView.frame.size.width - ButtonSizeWidth, self.pickerView.frame.origin.y - ButtonSizeHeight, ButtonSizeWidth, ButtonSizeHeight)];
    [self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.sureBtn];
    
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.sureBtn.frame.origin.y, self.pickerView.frame.size.width, self.pickerView.frame.size.height + self.sureBtn.frame.size.height)];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:backgroundView];
    [self sendSubviewToBack:backgroundView];
}

- (void)initDatas{
    
    NSArray *array = [NSArray arrayWithObjects:@"小于",@"等于",@"大于", nil];
    self.firstComponentDatas = array;
    
    NSArray *array2 = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17", nil];
    self.wsDatas = array2;
    
    NSMutableArray *array3 = [NSMutableArray array];
    for (int i=0; i<=40; i++) {
        [array3 addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    self.tempDatas = array3;
    
    NSMutableArray *array4 = [NSMutableArray array];
    for (int i=0; i<=100; i=i+10) {
        [array4 addObject:[NSString stringWithFormat:@"%d%%",i]];
    }
    self.sdDatas = array4;
    
    [self initMusicDatas];
}

- (void)initMusicDatas{
    NSArray *array = [[ItunesHelper shareInstance] getCAFMusicFromItunes];
    self.musicDatas = array;
}

- (void)buttonClick:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"取消"]) {
        
    }
    
    else{
        
        switch (self.type) {
            case MusicType:
                self.alarm.alarmMusic = [NSString stringWithString:self.contentString];
                break;
            case TempType:
                self.alarm.alarmTemp = [NSString stringWithString:self.contentString];
                break;
            case WSType:
                self.alarm.alarmWS = [NSString stringWithString:self.contentString];
                break;
            case SDType:
                self.alarm.alarmSD = [NSString stringWithString:self.contentString];
                break;
                
            default:
                break;
        }
    }
    
//    [AppDelegateInstance.mainManagedContext deleteObject:self.currentAlarm];
    [self.delegate reloadSettingDatas];
    [self removeFromSuperview];
}

- (void)setAlarm:(Alarm *)newAlarm{
    
    if (_alarm != newAlarm) {
        _alarm = newAlarm;
    }
    
//    if (self.currentAlarm == nil) {
//        NSEntityDescription *description = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:AppDelegateInstance.mainManagedContext];
//        _currentAlarm = [[Alarm alloc] initWithEntity:description insertIntoManagedObjectContext:AppDelegateInstance.mainManagedContext];
//    }
    
//    self.currentAlarm.alarmHour = _alarm.alarmHour;
//    self.currentAlarm.alarmMin = _alarm.alarmMin;
//    
//    self.currentAlarm.alarmMusic = [_alarm.alarmMusic mutableCopy];
////    [NSString stringWithString:_alarm.alarmMusic];
//    self.currentAlarm.alarmID = [_alarm.alarmID mutableCopy];
////    [NSString stringWithString:_alarm.alarmID];
//
//    self.currentAlarm.alarmTemp = [_alarm.alarmTemp mutableCopy];
////    [NSString stringWithString:_alarm.alarmTemp];
//    self.currentAlarm.alarmSD = [_alarm.alarmSD mutableCopy];
////    [NSString stringWithString:_alarm.alarmSD];
//    self.currentAlarm.alarmWS = [_alarm.alarmWS mutableCopy];
////    [NSString stringWithString:_alarm.alarmWS];
    
    
    switch (self.type) {
        case MusicType:{
            NSInteger row = [self.tempDatas indexOfObject:_alarm.alarmMusic];
            if (row == NSNotFound) {
                row = 0;
            }
            self.contentString = [self.musicDatas objectAtIndex:row];
            [self.pickerView selectRow:row inComponent:0 animated:YES];
            break;
        }
        case TempType:
            [self updateSelectedRow:_alarm.alarmTemp];
            break;
        
        case SDType:
            [self updateSelectedRow:_alarm.alarmSD];
            break;
            
        case WSType:
            [self updateSelectedRow:_alarm.alarmWS];
            break;
            
        default:
            break;
    }
}

- (void)updateSelectedRow:(NSString *)selectedString{
    
    NSArray *array = nil;
    switch (self.type) {
        case TempType:
            array = self.tempDatas;
            break;
        case WSType:
            array = self.wsDatas;
            break;
        case SDType:
            array = self.sdDatas;
            break;
        case MusicType:
            array = self.musicDatas;
            break;
            
        default:
            break;
    }
    if (selectedString) {
        self.contentString = selectedString;
        NSString *string = [selectedString substringToIndex:2];
        NSInteger row = [self.firstComponentDatas indexOfObject:string];
        [self.pickerView selectRow:row inComponent:0 animated:YES];
    
        string = [selectedString substringFromIndex:2];
        row = [array indexOfObject:string];
        [self.pickerView selectRow:row inComponent:1 animated:YES];
    }
    
    else{
        if (self.isOneComponent) {
            self.contentString = [array objectAtIndex:0];
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
        }
        
        else{
            self.contentString = [NSString stringWithFormat:@"%@%@",[self.firstComponentDatas objectAtIndex:0],[array objectAtIndex:0]];
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
            [self.pickerView selectRow:0 inComponent:1 animated:NO];
        }
        
    }
}

#pragma pickerview
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return ( (self.isOneComponent) ? 1 : 2);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.isOneComponent) {
        return self.musicDatas.count;
    }
    
    else{
        if (component == 0) {
            return self.firstComponentDatas.count;
        }
        else{
            switch (self.type) {
                case SDType:
                    return self.sdDatas.count;
                    break;
                case TempType:
                    return self.tempDatas.count;
                    break;
                case WSType:
                    return self.wsDatas.count;
                    break;
                    
                default:
                    return 0;
                     break;
                    
            }
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.isOneComponent ) {
        self.contentString = [self.musicDatas objectAtIndex:row];
        return self.contentString;
    }
    
    else{
        if (component == 0) {
            self.compareString = [self.firstComponentDatas objectAtIndex:row];
            return self.compareString;
        }
        else{
            NSArray *selectedArray;
            switch (self.type) {
                case SDType:
                    selectedArray = self.sdDatas;
                    break;
                case TempType:
                    selectedArray = self.tempDatas;
                    break;
                case WSType:
                    selectedArray = self.wsDatas;
                    break;

                default:
                    break;
                    
            }
            
            self.contentString = [selectedArray objectAtIndex:row];
            return self.contentString;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        if (self.isOneComponent) {
            
            self.contentString = [self.musicDatas objectAtIndex:row];
        }
        
        else{
            self.compareString = [self.firstComponentDatas objectAtIndex:row];
            self.contentString = [NSString stringWithFormat:@"%@%@",self.compareString,self.contentString];
        }
    }
    
    else{
        
        switch (self.type) {
            case SDType:
                self.contentString = [NSString stringWithFormat:@"%@%@",self.compareString,[self.sdDatas objectAtIndex:row]];

                break;
            case TempType:
                self.contentString = [NSString stringWithFormat:@"%@%@",self.compareString, [self.tempDatas objectAtIndex:row] ];

                break;
            case WSType:
                self.contentString = [NSString stringWithFormat:@"%@%@",self.compareString, [self.wsDatas objectAtIndex:row] ];

                
                break;
//            case MusicType:
//                
//                self.currentAlarm.alarmMusic = [self.musicDatas objectAtIndex:row];
//                break;
            default:
                break;
                
        }

    }
    

}

@end
