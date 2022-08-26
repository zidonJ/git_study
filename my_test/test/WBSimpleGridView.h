//
//  WBSimpleGridView.h
//  WBStory
//
//  Created by jiangzedong on 2021/3/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WBSimpleCollectionLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (void)completeLayoutHeight:(CGFloat)height;

@end

@interface WBSimpleCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic,weak) id<WBSimpleCollectionLayoutDelegate> amLayoutDelegate;

@end

@interface GridViewConfigModel : NSObject

@property (nonatomic, assign) BOOL itemWidthAdjust;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, assign) BOOL pageEnable;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) BOOL needSuportIrregularLayout; /// 支持不规则布局

@end

@protocol WBSimpleGridViewDelegate <NSObject>

@required
- (NSInteger)itemCount;
- (void)cellForItem:(UICollectionViewCell *)cell index:(NSIndexPath *)indexPath;

@optional
- (void)didSelectItem:(UICollectionViewCell *)cell index:(NSIndexPath *)indexPath;
- (CGSize)customConfigItemWidth:(NSIndexPath *)indexPath;

@end

@interface WBSimpleGridView : UIView

- (instancetype)initWithConfig:(nonnull void (^) (GridViewConfigModel *))block;

@property (nonatomic, weak) id<WBSimpleGridViewDelegate> delegate;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
- (void)seletIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
