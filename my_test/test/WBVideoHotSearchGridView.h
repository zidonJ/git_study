//
//  WBVideoHotSearchGridView.h
//  WBStory
//
//  Created by jiangzedong on 2022/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WBHotSearchCardConfigDelegate

@required
- (NSInteger)itemCount;
- (void)cellForItem:(UICollectionViewCell *)cell index:(NSIndexPath *)indexPath;

@optional
- (void)didSelectItem:(UICollectionViewCell *)cell index:(NSIndexPath *)indexPath;
- (CGSize)customConfigItemWidth:(NSIndexPath *)indexPath;

@end

@protocol WBHotSearchUniversalLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (void)completeLayoutHeight:(CGFloat)height;

@end

@interface WBIrregularityLayout : UICollectionViewFlowLayout

@property (nonatomic,weak) id<WBHotSearchUniversalLayoutDelegate> layoutDelegate;

@end

@interface WBHOtSearchGridViewConfigModel : NSObject

@property (nonatomic, assign) BOOL itemWidthAdjust;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) BOOL irregularityLayout;
@property (nonatomic, strong) __kindof UICollectionViewFlowLayout *customLayout; //可以自定义layout

@end

@interface WBVideoHotSearchGridView : UIView

- (instancetype)initWithConfig:(nonnull void (^) (WBHOtSearchGridViewConfigModel *))block;
@property (nonatomic, weak) NSObject<WBHotSearchCardConfigDelegate> *delegate;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
- (void)seletIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
