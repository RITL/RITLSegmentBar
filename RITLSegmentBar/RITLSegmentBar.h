//
//  RITLSegmentBar.h
//  RITLSegmentBarDemo
//
//  Created by YueWen on 2018/5/22.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RITLSegmentBar;

@protocol RITLSegmentBarDelegate <NSObject>

@optional

/**
 选择了按钮进行的回调

 @param segmentBar 选项卡控件
 @param toIndex 选中的位置
 @param fromIndex 原来选中的位置
 */
- (void)segmentBar:(RITLSegmentBar *)segmentBar
    didSelectIndex:(NSInteger)toIndex
         fromIndex:(NSInteger)fromIndex;


/// 当前位置是否能够响应点击时间
- (BOOL)segmentBar:(RITLSegmentBar *)segmentBar shouldActionAtIndex:(NSInteger)index;


/**
 初始化时自定义按钮属性的方法

 @param segmentBar segmentBar
 @param button 初始化的button
 @param index 按钮的索引
 */
- (void)segmentBar:(RITLSegmentBar *)segmentBar customButton:(UIButton *)button atIndex:(NSInteger)index;

@end

/// segmentBar
@interface RITLSegmentBar : UIView

/// 代理
@property (nonatomic, weak, nullable) id<RITLSegmentBarDelegate> delegate;
/// 数据源
@property (nonatomic, copy) NSArray <NSString *>*items;
/// 选中的索引
@property (nonatomic, assign)NSInteger selectIndex;

/// 快速创建一个选项卡控件
+ (instancetype)segmentBarWithFrame:(CGRect)frame;

#pragma mark - 视图
/// 指示器视图
@property (nonatomic, strong, readonly) UIImageView *indicatorView;
/// 所在位置的按钮
- (nullable UIButton *)buttonAtIndex:(NSInteger)index;

#pragma mark - 改变索引
/// 与selectIndex的区别在于该方法不执行点击回调，只改变UI
- (void)selectedIndex:(NSInteger)index;

#pragma mark - 功能扩充
/// 是否允许重复点击同一个button进行响应，默认为false
@property (nonatomic, assign, getter=shouldRepetAction)BOOL repetAction;
/// 是否允许滑动，默认为true，如果只想一屏显示，设置为false
@property (nonatomic, assign, getter=canScroll)BOOL scrollable;
/// 指示器是否根据数据源自动适配长度，默认为true
@property (nonatomic, assign, getter=isAutoFitItem)BOOL autoFitItem;

#pragma mark - 布局扩充
/// 响应按钮开始布局时的留白边.  默认为(2,23,0,23)
@property (nonatomic, assign)UIEdgeInsets contentMargin;
/// 指示器的固定宽度. 默认为14. isAutoFitItem = false时生效
@property (nonatomic, assign)CGFloat indicatorWidth;
/// 指示器的固定高度. 默认为2
@property (nonatomic, assign)CGFloat indicatorHeight;
/// 指示器偏离底部的边距. 默认为0
@property (nonatomic, assign)CGFloat indicatorMarginBottom;
/// 文字自适应后按钮自身进行拓展的长度，默认为 0
@property (nonatomic, assign)CGFloat buttonExpandedSpace;
/// 文字按钮的固定间距, 设置后按照设置的间距进行排列，默认为 RITLSegmentBarButtonsMarginSpaceDefault
@property (nonatomic, assign)CGFloat buttonMarginSpace;
/// 文字响应按钮的固定高度，默认 RITLSegmentBarButtonsHeightDefault
@property (nonatomic, assign)CGFloat buttonHeight;
/// 文字响应按钮的固定宽度，默认 RITLSegmentBarButtonsWidthDefault
@property (nonatomic, assign)CGFloat buttonWidth;
/// 文字选中，如果需要修改大小，默认为buttonHeight
@property (nonatomic, assign)CGFloat buttonSelectedHeight;

#pragma mark - UI属性扩充
/// 默认下的item颜色,默认为lightGrayColor
@property (nonatomic, strong) UIColor *itemNormalColor;
/// 选中的item颜色,默认为red
@property (nonatomic, strong) UIColor *itemSelectedColor;
/// item的背景色,默认为clearColor
@property (nonatomic, strong) UIColor *itemBackgroungColor;
/// 默认下的item字体,默认为15
@property (nonatomic, strong) UIFont *itemNormalFont;
/// 选中的item字体,默认为itemNormalFont
@property (nonatomic, strong) UIFont *itemSelectedFont;
/// item的圆角，默认为0
@property (nonatomic, assign)CGFloat itemRadius;
/// 根据UI属性更新所有Item的变化
- (void)updateAllItems;
/// 根据UI属性更新所有视图的变化
- (void)updateAllItemsAndViews;

@end

/// 默认的按钮间距
extern CGFloat RITLSegmentBarButtonsMarginSpaceDefault;
/// 默认的文本高度
extern CGFloat RITLSegmentBarButtonsHeightDefault;
/// 默认的文本宽度
extern CGFloat RITLSegmentBarButtonsWidthDefault;

NS_ASSUME_NONNULL_END
