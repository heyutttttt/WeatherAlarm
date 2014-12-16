//
//  SettingPickerView.h
//  WeatherAlarm
//
//  Created by RYAN on 14/12/1.
//  Copyright (c) 2014年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

typedef enum {
    MusicType,
    WSType,
    TempType,
    SDType
    
}PickerType;

@protocol SettingPickerViewDelegate <NSObject>

- (void)reloadSettingDatas;

@end

@interface SettingPickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, assign) BOOL isOneComponent;
@property (nonatomic, assign) PickerType type;
@property (nonatomic, strong) Alarm *alarm;

@property (nonatomic, assign) id<SettingPickerViewDelegate> delegate;

@end
