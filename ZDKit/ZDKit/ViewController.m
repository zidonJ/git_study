//
//  ViewController.m
//  ZDKit
//
//  Created by jiangzedong on 2022/7/19.
//

#import "ViewController.h"
#import "MyLabel.h"
#import "NSAttributedString+TextKit.h"
#import "ZDAttribute.h"

@interface ViewController () {
    MyLabel *_mLabel;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    _mLabel = [[MyLabel alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 500)];
    _mLabel.backgroundColor = UIColor.lightGrayColor;
    _mLabel.numberOfLines = 5;
    _mLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _mLabel.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
    NSString *str = @"君不见黄河之水天上来，奔流到海不复回。"
    "君不见高堂明镜悲白发，朝如青丝暮成雪。"
    "人生得意须尽欢，莫使金樽空对月。"
    "天生我材必有用，千金散尽还复来。"
    "烹羊宰牛且为乐，会须一饮三百杯。"
    "岑夫子，丹丘生，将进酒，杯莫停。"
    "与君歌一曲，请君为我倾耳听。"
    "钟鼓馔玉不足贵，但愿长醉不愿醒。"
    "古来圣贤皆寂寞，惟有饮者留其名。"
    "陈王昔时宴平乐，斗酒十千恣欢谑。"
    "主人何为言少钱，径须沽取对君酌。"
    "五花马、千金裘，呼儿将出换美酒，与尔同销万古愁。";
    str = @"君不见黄河之水天上来，奔流到海不复回。君不见高堂明镜悲白发，朝如青丝暮成雪。人生得意须尽欢，莫使金樽空对月。天生我材必有用，千金散尽还复来。烹羊宰牛且为乐，会须一饮三百杯。岑夫子，丹丘生，将进酒，杯莫停。与君歌一曲，请君为我倾耳听。钟鼓馔玉不足贵，但愿长醉不愿醒。古来圣贤皆寂寞，惟有饮者留其名。陈王昔时宴平乐，斗酒十千恣欢谑。主人何为言少钱，径须沽取对君酌。五花马、千金裘，呼儿将出换美酒，与尔同销万古愁。";
    //_mLabel.text = str;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str];
    [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:UIColor.redColor} range:NSMakeRange(0, str.length)];
    [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30],NSForegroundColorAttributeName:UIColor.greenColor} range:NSMakeRange(3, 1)];
    _mLabel.attributedText = att;
    
    _mLabel.truncation = [self truncation];
    
    [self.view addSubview:_mLabel];
    
}

- (NSAttributedString *)truncation {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"...全文"];
    text.zd_font = [UIFont systemFontOfSize:16];
    [text zd_addColor:[UIColor redColor] range:[text.string rangeOfString:@"全文"]];
    ZDAttribute *textHighlight = [[ZDAttribute alloc]init];
    textHighlight.color = [UIColor blueColor];
    textHighlight.tag = 1000;
    [text addTextAttribute:textHighlight range:[text.string rangeOfString:@"全文"]];
    text.zd_characterSpacing = 2;
    return text;
}



@end
