//
//  MyViewController.m
//  test
//
//  Created by jiangzedong on 2021/8/17.
//

#import "MyViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Simple.h"

NSString *getNetTypeInfo(void)
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    NSDictionary *dict;
    NSString *currentStatus;
    if (@available(iOS 12.0, *)) {
        dict = info.serviceCurrentRadioAccessTechnology;
        currentStatus = [[info.serviceCurrentRadioAccessTechnology allValues] firstObject];
    }
    if (!currentStatus) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        currentStatus = info.currentRadioAccessTechnology;
#pragma clang diagnostic pop
    }
    NSString *currentNet = @"UNKNOW";
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
        currentNet = @"GPRS";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
         currentNet = @"GPRS";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]){
         currentNet = @"2G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]){
         currentNet = @"3G";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
         currentNet = @"4G";
    } else if (@available(iOS 14.0, *)) {
        if (@available(iOS 14.1, *)) {
            if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]){
                currentNet = @"5G";
            } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyNR]){
                currentNet = @"5G";
            }
        } else {
            
        }
    }
    return currentNet;
}

double getBatteryInfo(void)
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    return deviceLevel;
}





@interface WBSVTimeInfo : NSObject

@end

@implementation WBSVTimeInfo

+ (void)is12HourFormat:(void (^) (BOOL is12Hour,NSString *))call {

    UIApplication *app = [UIApplication sharedApplication];
    NSString *timeStrValue = nil;
    @try {
    
        id statusBar = [[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"statusBar"];
        id data = [statusBar valueForKeyPath:@"currentData"];
        id timeEntry = [data valueForKeyPath:@"timeEntry"];
        timeStrValue = [timeEntry valueForKeyPath:@"stringValue"];
        
    } @catch (NSException *exception) {

    } @finally {
        if (!timeStrValue) {
            NSLocale *local = [NSLocale autoupdatingCurrentLocale];
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            calendar.locale = local;
            
            NSString *dateStr = [[NSDate date] descriptionWithLocale:local];
            
            NSString *amSymbol = [calendar AMSymbol];
            NSString *pmSymbol = [calendar PMSymbol];
            BOOL is12Hour = NO;
            for (NSString *symbol in @[amSymbol,pmSymbol]) {
                if ([dateStr rangeOfString:symbol].location != NSNotFound) {
                    is12Hour = YES;
                    break;
                }
            }
            !call?:call(is12Hour,dateStr);
            return;
        }
    }
    
    NSCharacterSet *numberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789 :"] invertedSet];
    NSString *filtered = [[timeStrValue componentsSeparatedByCharactersInSet:numberSet] componentsJoinedByString:@""];
    BOOL is12Hour = ![timeStrValue isEqualToString:filtered];
    
    !call?:call(is12Hour,timeStrValue);
}

@end

@interface WBSVNetStateView : UIView

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *netLabel;

@end

@implementation WBSVNetStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig
{
    [self addSubview:self.imgView];
    [self addSubview:self.netLabel];
}

- (void)setNetType:(NSString *)netType
{
    if ([netType isEqualToString:@"WIFI"]) {
        _netLabel.hidden = YES;
        _imgView.hidden = NO;
        [self suitSize:_imgView.size];
    } else {
        _netLabel.hidden = NO;
        _imgView.hidden = YES;
        _netLabel.text = netType;
        [_netLabel sizeToFit];
        [self suitSize:_netLabel.size];
    }
}

- (void)suitSize:(CGSize)size
{
    self.size = size;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15.3, 11)];
        _imgView.image = [UIImage imageNamed:@"video_fullscreen_icon_Wi-Fi"];
    }
    return _imgView;
}

- (UILabel *)netLabel
{
    if (!_netLabel) {
        _netLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _netLabel.textColor = UIColor.whiteColor;
        _netLabel.font = [UIFont fontWithName:@"SFProText-Regular" size:12];
    }
    return _netLabel;
}

@end

@interface WBSVBatteryView : UIView
{
    CGFloat _fullBattery;
}
@property (strong, nonatomic) UIImageView *imgView;
@property (nonatomic, strong) UIView *batteryView;

@end

@implementation WBSVBatteryView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 25, 12)]) {
        _fullBattery = 18;
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig
{
    _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imgView.image = [UIImage imageNamed:@"video_fullscreen_icon_battery"];
    [self addSubview:_imgView];
    
    _batteryView = [[UIView alloc] initWithFrame:CGRectZero];
    _batteryView.backgroundColor = UIColor.whiteColor;
    _batteryView.frame = CGRectMake(2.0, 0, 1, 7.3);
    _batteryView.centerY = _imgView.height/2;
    _batteryView.layer.masksToBounds = YES;
    _batteryView.layer.cornerRadius = 1.33;
    [_imgView addSubview:_batteryView];
}

- (void)setBatteryPercent:(CGFloat)percent
{
    _batteryView.width = _fullBattery*percent;
}


@end

@interface WBSVTimeView : UIView

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation WBSVTimeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig
{
    [self addSubview:self.timeLabel];
}

- (void)updateTime:(NSString *)text
{
    self.timeLabel.text = text;
    [self.timeLabel sizeToFit];
    self.size = self.timeLabel.size;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont fontWithName:@"SFProText-Regular" size:12];
        _timeLabel.textColor = UIColor.whiteColor;
    }
    return _timeLabel;
}

@end

@interface WBSVStatusBarView : UIView

@property (nonatomic, strong) WBSVNetStateView *netView;
@property (nonatomic, strong) WBSVBatteryView *batteryView;
@property (nonatomic, strong) WBSVTimeView *timeView;

@end

@implementation WBSVStatusBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig
{
    [self addSubview:self.netView];
    [self addSubview:self.batteryView];
    [self addSubview:self.timeView];
}

- (void)layoutSubviews
{
    _batteryView.right = self.width - 50;
    _batteryView.centerY = self.height/2;
    
    _netView.right = _batteryView.x - 7;
    _netView.centerY = _batteryView.centerY;
    
    _timeView.centerX = self.width/2;
    _timeView.centerY = _netView.centerY;
}

- (void)updateTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [WBSVTimeInfo is12HourFormat:^(BOOL is12Hour, NSString *timeString) {
        if (is12Hour) {
            formatter.dateFormat = @"hh:mm";
        } else {
            formatter.dateFormat = @"HH:mm";
        }
        //formatter.timeStyle = NSDateFormatterShortStyle;
        NSString *current = [formatter stringFromDate:date];
        
        NSString *symbol;
        if (is12Hour) {
            if ([timeString containsString:formatter.AMSymbol]) {
                symbol = @"上午";
            } else {
                symbol = @"下午";
            }
            current = [symbol stringByAppendingFormat:@" %@",current];
        }
        [self.timeView updateTime:current];
    }];
}

- (void)updateNetStatus
{
    [self.netView setNetType:@"WIFI"];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)updateBatteryPercent
{
    [self.batteryView setBatteryPercent:getBatteryInfo()];
}

- (void)updateStatusBar
{
    [self updateTime];
    [self updateNetStatus];
    [self updateBatteryPercent];
}

- (WBSVNetStateView *)netView
{
    if (!_netView) {
        _netView = [[WBSVNetStateView alloc] initWithFrame:CGRectMake(0, 0, 15.3, 11)];
    }
    return _netView;
}

- (WBSVBatteryView *)batteryView
{
    if (!_batteryView) {
        _batteryView = [[WBSVBatteryView alloc] initWithFrame:CGRectMake(0, 0, 25, 12)];
    }
    return _batteryView;
}

- (WBSVTimeView *)timeView
{
    if (!_timeView) {
        _timeView = [[WBSVTimeView alloc] initWithFrame:CGRectMake(0, 0, 100, 12)];
    }
    return _timeView;
}

@end

@interface MyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *battery;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *netType;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) UIView *batteryView;

@property (nonatomic, strong) WBSVStatusBarView *stBarView;

@end


@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _batteryView = [[UIView alloc] initWithFrame:CGRectZero];
    _batteryView.backgroundColor = UIColor.whiteColor;
    _batteryView.frame = CGRectMake(0, 0, 5, 7.3);
    _batteryView.layer.masksToBounds = YES;
    _batteryView.layer.cornerRadius = 1.33;
    [_imgView addSubview:_batteryView];
    
    _stBarView = [[WBSVStatusBarView alloc] initWithFrame:CGRectMake(0, 400, self.view.width, 20)];
    _stBarView.backgroundColor = UIColor.systemBlueColor;
    [self.view addSubview:_stBarView];
}

- (void)viewDidLayoutSubviews
{
    _batteryView.x = 2;
    _batteryView.centerY = _imgView.height/2;
}

- (void)getCurrentTimeInfo
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [WBSVTimeInfo is12HourFormat:^(BOOL is12Hour, NSString *timeString) {
        if (is12Hour) {
            formatter.dateFormat = @"hh:mm";
        } else {
            formatter.dateFormat = @"HH:mm";
        }
        //formatter.timeStyle = NSDateFormatterShortStyle;
        NSString *current = [formatter stringFromDate:date];
        
        NSString *symbol;
        if (is12Hour) {
            if ([timeString containsString:formatter.AMSymbol]) {
                symbol = @"上午";
            } else {
                symbol = @"下午";
            }
            current = [symbol stringByAppendingFormat:@" %@",current];
        }
        self.time.text = current;
    }];
}

- (IBAction)getInfoAction:(id)sender {
    
    getBatteryInfo();
    [self getCurrentTimeInfo];
    getNetTypeInfo();
    
    
    [_stBarView updateStatusBar];
}


@end
