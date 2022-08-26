//
//  WBSimpleGridView.m
//  WBStory
//
//  Created by jiangzedong on 2021/3/17.
//

#import "WBSimpleGridView.h"

@interface UICollectionViewLayoutAttributes (LeftAligned)

- (void)alignFrameWithSectionInset:(UIEdgeInsets)sectionInset;
@property (nonatomic, assign) CGFloat wbt_attLeft;
@property (nonatomic, assign) CGFloat wbt_attRight;

@end

@implementation UICollectionViewLayoutAttributes (LeftAligned)

@dynamic wbt_attLeft,wbt_attRight;

- (void)alignFrameWithSectionInset:(UIEdgeInsets)sectionInset {
    
    CGRect frame = self.frame;
    frame.origin.x = sectionInset.left;
    self.frame = frame;
}

- (CGFloat)wbt_attRight
{
    return self.frame.size.width + self.frame.origin.x;
}

- (void)setWbt_attRight:(CGFloat)wbt_attRight
{
    CGRect frame = self.frame;
    frame.origin.x = wbt_attRight - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)wbt_attLeft
{
    return self.frame.origin.x;
}

- (void)setWbt_attLeft:(CGFloat)wbt_attLeft
{
    CGRect frame = self.frame;
    frame.origin.x = wbt_attLeft;
    self.frame = frame;
}

@end

@interface WBSimpleCollectionLayout ()

{
    CGFloat _completeContentSizeHeight;
}

@end

@implementation WBSimpleCollectionLayout

#pragma mark - UICollectionViewLayout

//- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//
//    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
//    for (UICollectionViewLayoutAttributes *attributes in attributesToReturn) {
//        //header or footer or cell  cell为nil
//        if (nil == attributes.representedElementKind) {
//            NSIndexPath *indexPath = attributes.indexPath;
//            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
//        }
//    }
//    return attributesToReturn;
//}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    UICollectionViewLayoutAttributes *currentItemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
//    UIEdgeInsets sectionInset = [self evaluatedSectionInsetForItemAtIndex:indexPath.section];
    
//    BOOL isFirstItemInSection = indexPath.item == 0;
//
//    CGFloat layoutWidth = CGRectGetWidth(self.collectionView.frame) - sectionInset.left - sectionInset.right;
//    if (isFirstItemInSection) {
//        [currentItemAttributes alignFrameWithSectionInset:sectionInset];
//        return currentItemAttributes;
//    }
//
//    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
//    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
//    if (indexPath.item >= 1) {
//        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
//        UICollectionViewLayoutAttributes *previousAttributes = [self layoutAttributesForItemAtIndexPath:previousIndexPath];
//        
//        currentItemAttributes.wbt_attLeft = previousAttributes.wbt_attRight + 28.0;
//    }

//    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width;
//    CGRect currentFrame = currentItemAttributes.frame;
//    CGRect strecthedCurrentFrame = CGRectMake(sectionInset.left,
//                                              currentFrame.origin.y,
//                                              layoutWidth,
//                                              currentFrame.size.height);
//
//    // if the current frame, once left aligned to the left and stretched to the full collection view
//    // widht intersects the previous frame then they are on the same line
//    BOOL isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame);
//
//    if (isFirstItemInRow) {
//        // make sure the first item on a line is left aligned
//        [currentItemAttributes alignFrameWithSectionInset:sectionInset];
//        return currentItemAttributes;
//    }
//
//    CGRect frame = currentItemAttributes.frame;
//    frame.origin.x = previousFrameRightPoint + [self evaluatedMinimumInteritemSpacingForItemAtIndex:indexPath.item];
//    currentItemAttributes.frame = frame;
//    return currentItemAttributes;
//}

- (CGFloat)evaluatedMinimumInteritemSpacingForItemAtIndex:(NSInteger)index {
    
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        id<WBSimpleCollectionLayoutDelegate> delegate = (id<WBSimpleCollectionLayoutDelegate>)self.collectionView.delegate;
        
        return [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:index];
    } else {
        return self.minimumLineSpacing;
    }
}

- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index {
    
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        id<WBSimpleCollectionLayoutDelegate> delegate = (id<WBSimpleCollectionLayoutDelegate>)self.collectionView.delegate;
        
        return [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    } else {
        return self.sectionInset;
    }
}

#pragma mark -- getters setters --

- (CGSize)collectionViewContentSize {
    
    return [super collectionViewContentSize];
}
@end

@interface WBSimpleGridView () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,WBSimpleCollectionLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GridViewConfigModel *configModel;
NSString *classToString(Class clz);

@end

@implementation WBSimpleGridView

NSString *classToString(Class clz) {
    if (!clz) {
        return nil;
    }
    return NSStringFromClass(clz);
}

- (instancetype)initWithConfig:(void (^)(GridViewConfigModel * _Nonnull))block
{
    if (self = [super initWithFrame:CGRectZero]) {
        !block?:block(self.configModel);
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews
{
    self.collectionView.frame = self.bounds;
}

- (void)seletIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

//MARK: UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItem:index:)]) {
        [self.delegate didSelectItem:[collectionView cellForItemAtIndexPath:indexPath] index:indexPath];
    }
}

//MARK: UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.configModel.itemWidthAdjust) {
        CGFloat width = [self.delegate customConfigItemWidth:indexPath].width;
        return CGSizeMake(width, self.configModel.itemSize.height);
    }
    return self.configModel.itemSize;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 20, 0, 20);
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return self.configModel.minimumLineSpacing;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return self.configModel.minimumInteritemSpacing;
//}

//MARK: UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate itemCount];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:classToString(self.configModel.cellClass)
                                                                           forIndexPath:indexPath];
    [self.delegate cellForItem:cell index:indexPath];
    return cell;
}

//MARK: getter
- (GridViewConfigModel *)configModel
{
    if (!_configModel) {
        _configModel = [[GridViewConfigModel alloc] init];
    }
    return _configModel;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout;
//        if (self.configModel.needSuportIrregularLayout) {
//            layout = [[WBSimpleCollectionLayout alloc] init];
//            [(WBSimpleCollectionLayout *)layout setAmLayoutDelegate:self];
//        } else {
            layout = [[UICollectionViewFlowLayout alloc] init];
//        }
        layout.scrollDirection = self.configModel.scrollDirection;
        layout.minimumLineSpacing = self.configModel.minimumLineSpacing;
        layout.minimumInteritemSpacing = self.configModel.minimumInteritemSpacing;
        layout.itemSize = self.configModel.itemSize;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.contentInset = self.configModel.insets;
        _collectionView.pagingEnabled = self.configModel.pageEnable;

        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceHorizontal = NO;
        [_collectionView registerClass:self.configModel.cellClass forCellWithReuseIdentifier:classToString(self.configModel.cellClass)];
    }
    return _collectionView;
}


@end

@implementation GridViewConfigModel

@end

