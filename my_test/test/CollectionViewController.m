//
//  CollectionViewController.m
//  test
//
//  Created by jiangzedong on 2022/8/9.
//

#import "CollectionViewController.h"
#import "WBSimpleGridView.h"

@interface WBInteractOptionItem : UICollectionViewCell

@property (nonatomic, strong) UILabel *optionLabel;

@end

@implementation WBInteractOptionItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig
{
    _optionLabel = [UILabel new];
    _optionLabel.font = [UIFont systemFontOfSize:18];
    _optionLabel.backgroundColor = UIColor.lightGrayColor;
    _optionLabel.textColor = UIColor.greenColor;
    _optionLabel.numberOfLines = 1;
    _optionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_optionLabel];
}

- (void)layoutSubviews
{
    [_optionLabel sizeToFit];
    CGRect rect = _optionLabel.frame;
    if (_optionLabel.frame.size.width > 200.0) {
        rect.size.width = 200.0;
        _optionLabel.frame = rect;
    }
//    _optionLabel.frame = CGRectMake(14, 0, self.frame.size.width-28, self.frame.size.height);
}

@end

@interface CollectionViewController () <WBSimpleGridViewDelegate>

@property (nonatomic, strong) WBSimpleGridView *gridView;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray *strings;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _size = CGSizeMake(100, 28);
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.gridView];
    self.gridView.frame = CGRectMake(0, 100, self.view.frame.size.width, 100);
    _strings = @[@"我这就下载到 usr/local 目录下了，",
                 @"顺丰洛杉矶市地方",
                 @"wget https://dl.google.com/go/go1.13.5.linux-amd64.tar.g",
                 @"顺丰洛水淀粉水淀粉水淀粉水淀粉杉矶",
                 @"新民晚报—海上客消息，中国人民解放军展开重要军事演训活动以后，台湾地区民进党当局故作镇定，一开始还欺骗民众，称台军对解放军演训“尽在掌握”。当他们的谎言被揭穿以后，这两天又有人放风称，未来台北故宫博物院文物可能送到美国、日本去。",
                 @"在海叔看来，台北故宫博物院",@"放军重要军事演训行动开始以后，台湾地区网上有传",
                 @"9年国民党败退迁台的？其与如今大陆诸如北京故宫9年国民党败退迁台的？其与如今大陆诸如北京故宫",
                 @"解放军演训开始后，民进党当局一度不肯承认解放军导弹飞越台湾上空。直到",@"这个有关台北故宫博物院文物的说法，极其恶毒",
                 @"这种骗术，只能骗鬼。8月9日，又爆出台军炮击训练之事。什么意思？还想螳臂挡车",@"顺丰洛杉矶",
                 @"顺丰啊实打实的洛杉矶",@"大陆诸如北京故宫",@"系出一脉",
                 @"顺丰洛杉矶",@"顺丰 说的分手洛杉矶",@"已经打不出几张阻止解放军反“台独”",
                 @"多数还不是1949年国民党败退迁台的？其与如今大陆诸如北京故宫博物院藏品等",@"顺丰洛杉矶",
                 @"流到伪“满洲国”长春所谓皇宫的有之",@"顺丰洛水淀粉水淀粉杉矶",@"顺丰洛杉矶",@"仪曾经带出",
                 @"在中华民族孱弱的时刻，故宫文物经历过种种磨难。如今中华",@"台湾地区一些人，最好不要逆流而",@"顺丰洛 水淀粉杉矶",
                 @"顺丰水淀粉水淀粉洛杉矶",@"顺丰水淀粉水淀粉洛杉矶",@"顺丰洛杉矶萨达"].mutableCopy;
}

- (NSInteger)itemCount
{
    return _strings.count;
}

- (void)cellForItem:(WBInteractOptionItem *)cell index:(NSIndexPath *)indexPath
{
    cell.backgroundColor = UIColor.redColor;
    cell.optionLabel.text = _strings[indexPath.item];
}

- (void)didSelectItem:(UICollectionViewCell *)cell index:(NSIndexPath *)indexPath
{
//    self.size = CGSizeMake(self.size.width + 10, self.size.height);
//    [self.gridView reloadData];
}

- (CGSize)customConfigItemWidth:(NSIndexPath *)indexPath
{
    CGSize size = [_strings[indexPath.item] boundingRectWithSize:CGSizeMake(300, 20) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size;
    return CGSizeMake(size.width > 200 ? 200:size.width, 100);
    return CGSizeMake(_gridView.frame.size.width, 100);
}

- (WBSimpleGridView *)gridView
{
    if (!_gridView) {
        _gridView = [[WBSimpleGridView alloc] initWithConfig:^(GridViewConfigModel * _Nonnull model) {
            model.needSuportIrregularLayout = YES;
            model.itemWidthAdjust = YES;
            model.cellClass = WBInteractOptionItem.class;
            model.itemSize = CGSizeMake(self.view.frame.size.width, 100);
            model.minimumLineSpacing = 30;
//            model.minimumInteritemSpacing = 30;
            model.pageEnable = YES;
//            model.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            model.scrollDirection = UICollectionViewScrollDirectionVertical;
        }];
        _gridView.delegate = self;
    }
    return _gridView;
}

@end
