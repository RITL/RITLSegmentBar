//
//  RITLSegmentBar.m
//  RITLSegmentBarDemo
//
//  Created by YueWen on 2018/5/22.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "RITLSegmentBar.h"
#import <Foundation/Foundation.h>

@interface UIView (RITLSegmentBar)
@property (nonatomic, assign) CGFloat seg_x;
@property (nonatomic, assign) CGFloat seg_y;
@property (nonatomic, assign) CGFloat seg_width;
@property (nonatomic, assign) CGFloat seg_height;
@property (nonatomic, assign) CGFloat seg_centerX;
@property (nonatomic, assign) CGFloat seg_centerY;
@end

CGFloat RITLSegmentBarButtonsHeightDefault = -1;
CGFloat RITLSegmentBarButtonsMarginSpaceDefault = -1;


@interface RITLSegmentBar()
/// 内容承载的视图
@property (nonatomic, strong) UIScrollView *contentView;
/// 存放响应按钮的数组
@property (nonatomic, strong) NSMutableArray<UIButton *> *itemBtns;
/// 指示器
@property (nonatomic, strong, readwrite) UIImageView *indicatorView;
/// 记录最后一次点击的索引
@property (nonatomic, assign)NSInteger lastIndex;

/// 选择当前索引，是否唤起delegate
- (void)selectedIndex:(NSInteger)index actionDelegate:(BOOL)shouldAction;

@end

@implementation RITLSegmentBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
     
        [self prepareForUse];//设置默认值
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self prepareForUse];
}

/// 初始化所有的信息
- (void)prepareForUse
{
    self.itemBtns = [NSMutableArray arrayWithCapacity:10];
    _selectIndex = 0;
    self.lastIndex = -1;//默认为-1
    self.repetAction = false;
    self.scrollable = true;
    self.autoFitItem = true;
    self.itemRadius = 0;
    self.indicatorWidth = 14;
    self.indicatorHeight = 2;
    self.indicatorMarginBottom = 0;
    self.buttonExpandedSpace = 0;
    self.buttonMarginSpace = RITLSegmentBarButtonsMarginSpaceDefault;
    self.buttonHeight = RITLSegmentBarButtonsHeightDefault;
    self.buttonSelectedHeight = RITLSegmentBarButtonsHeightDefault;
    self.contentMargin = UIEdgeInsetsMake(2, 23, 0, 23);
}


+ (instancetype)segmentBarWithFrame:(CGRect)frame
{
    return [[self alloc]initWithFrame:frame];
}

#pragma mark - index

- (void)btnDidClick:(UIButton *)sender
{
    [self setSelectIndex:[self.itemBtns indexOfObject:sender]];
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    if (self.items.count == 0 || selectIndex < 0 || selectIndex > self.itemBtns.count- 1) { return; }
    [self selectedIndex:selectIndex actionDelegate:true];
}


- (void)selectedIndex:(NSInteger)index
{
    if (self.items.count == 0 || index < 0 || index > self.itemBtns.count- 1) { return; }
    [self selectedIndex:index actionDelegate:false];
}


- (void)selectedIndex:(NSInteger)index actionDelegate:(BOOL)shouldAction
{
    if (self.lastIndex != _selectIndex) {
        self.lastIndex = _selectIndex;
    }
    _selectIndex =  index;
    
    if (self.shouldRepetAction) {//如果允许重复响应
        if (shouldAction && [self.delegate respondsToSelector:@selector(segmentBar:didSelectIndex:fromIndex:)]){
            [self.delegate segmentBar:self didSelectIndex:index fromIndex:self.lastIndex];
        }
    }else {//如果不允许重复响应
        if (shouldAction && index != self.lastIndex && [self.delegate respondsToSelector:@selector(segmentBar:didSelectIndex:fromIndex:)]) {
            [self.delegate segmentBar:self didSelectIndex:index fromIndex:self.lastIndex];
        }
    }
    
    //获得按钮
    UIButton *lastBtn = self.itemBtns[self.lastIndex];
    [lastBtn setAttributedTitle:[self attributeAtIndex:self.lastIndex] forState:UIControlStateNormal];
    UIButton *selectBtn = self.itemBtns[index];
    [selectBtn setAttributedTitle:[self attributeAtIndex:index] forState:UIControlStateNormal];
    
    [self setNeedsLayout];//重新布置
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        if (self.isAutoFitItem) {
            self.indicatorView.seg_width = selectBtn.seg_width;
        }else {
            self.indicatorView.seg_width = self.indicatorWidth;
        }
        self.indicatorView.seg_centerX = selectBtn.seg_centerX;
    }];
    
    //进行滚动
    CGFloat scrollX = MIN(self.contentView.contentSize.width - self.contentView.seg_width,MAX(0,selectBtn.seg_x - self.contentView.seg_width / 2.0));
    
//    scrollX = self.seg_width == 0 ? 0 : scrollX;//避免autolayout引起的初始化位置失败
    scrollX = self.seg_width == 0 ? 0 : MAX(0,scrollX);//避免autolayout引起的初始化位置失败
    [self.contentView setContentOffset:CGPointMake(scrollX, 0) animated:true];
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.contentView.backgroundColor = backgroundColor;
}


- (UIButton *)buttonAtIndex:(NSInteger)index
{
    if (index >= self.itemBtns.count || index < 0) { return nil; }
    
    return self.itemBtns[index];
}


#pragma mark - Items

- (void)setItems:(NSArray<NSString *> *)items
{
    _items = items;
    [self.itemBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemBtns removeAllObjects];
    
    for (NSString *item in items) {
        
        NSInteger index = [items indexOfObject:item];
        UIButton *button = [UIButton new];
        
        [button setAttributedTitle:[self attributeAtIndex:index] forState:UIControlStateNormal];
        button.backgroundColor = self.itemBackgroungColor;
        button.layer.cornerRadius = self.itemRadius;
        button.clipsToBounds = (self.itemRadius != 0);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:button];
        [self.itemBtns addObject:button];
        
        [button addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (NSAttributedString *)attributeAtIndex:(NSInteger)index
{
    if (index == self.selectIndex) {
        return [self attributeSelectedTitleWithString:self.items[index]];
    }
    return [self attributeNormalTitleWithString:self.items[index]];
}

- (NSAttributedString *)attributeNormalTitleWithString:(NSString *)title
{
    return [[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:self.itemNormalColor,NSFontAttributeName:self.itemNormalFont}];
}

- (NSAttributedString *)attributeSelectedTitleWithString:(NSString *)title
{
    return [[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:self.itemSelectedColor,NSFontAttributeName:self.itemSelectedFont}];
}


#pragma mark - subviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    
    if (self.itemBtns.count == 0) { return; }//如果按钮不存在，不进行操作
    
    CGFloat contentSizeWidth = 0;
    CGFloat totalBtnWidth = 0;//所有button的宽度
    
    // 开始高度布局
    for (UIButton *btn in self.itemBtns) {
        
        [btn sizeToFit];
        btn.seg_width = btn.seg_width + self.buttonExpandedSpace;
        
        if (self.buttonHeight != RITLSegmentBarButtonsHeightDefault) {//如果存在设置的高度进行设置
            btn.seg_height = self.buttonHeight;
        }
        totalBtnWidth += (btn.seg_width + self.buttonExpandedSpace);
        
        NSInteger index = [self.itemBtns indexOfObject:btn];
        NSLog(@"I am %@, my size is %@,I am %@",self.items[index],NSStringFromCGSize(btn.bounds.size),btn.selected ? @"selected" : @"unSelected");
    }
    
    NSLog(@"\n");
    
    if (self.buttonSelectedHeight != RITLSegmentBarButtonsHeightDefault) {
        
        self.itemBtns[self.selectIndex].seg_height = self.buttonSelectedHeight;
    }
    
    // 开始计算间距
    contentSizeWidth += totalBtnWidth;
    CGFloat buttonsSpace = 0;//用于存储计算按钮的间距
    CGFloat lastX = ABS(self.contentMargin.left);//记录最新的距离
    
    if (!self.canScroll) {//如果是不可以滑动的,进行均分
        
        NSAssert(self.seg_width - totalBtnWidth - self.contentMargin.left - self.contentMargin.right > 0, @"当前frame不足以展示所有的items");
        
        buttonsSpace = (self.seg_width - totalBtnWidth - ABS(self.contentMargin.left) - ABS(self.contentMargin.right)) / (self.itemBtns.count - 1);
    }
    
    if (self.buttonMarginSpace != RITLSegmentBarButtonsMarginSpaceDefault) {//不是默认的
        buttonsSpace = self.buttonMarginSpace;
    }

    //开始按钮布局
    for (UIButton *button in self.itemBtns) {
        button.seg_x = lastX;
        lastX += (button.seg_width + buttonsSpace);
        contentSizeWidth += buttonsSpace;
        
        // 保证所有的中心一致
        button.seg_centerY = (self.contentView.seg_height - self.contentMargin.top - self.contentMargin.bottom) / 2.0;
    }
    
    contentSizeWidth += self.contentMargin.right;

    self.contentView.contentSize = !self.canScroll ? CGSizeMake(self.seg_width, self.seg_height) : CGSizeMake(contentSizeWidth, self.seg_height);
    
    //获得选择的btn
    UIButton *selectedButton = self.itemBtns[self.selectIndex];
    
    //指示器
    if (self.isAutoFitItem) {
        self.indicatorView.seg_width = selectedButton.seg_width - self.buttonExpandedSpace;
    }else {
        self.indicatorView.seg_width = self.indicatorWidth;
    }
    
    self.indicatorView.seg_centerX = selectedButton.seg_centerX;
    self.indicatorView.seg_height = self.indicatorHeight;
    self.indicatorView.seg_y = self.seg_height - ABS(self.indicatorHeight) - ABS(self.indicatorMarginBottom);
}


#pragma mark - update

- (void)updateAllItems
{
    [self.itemBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSString *item = self.items[idx];
        
        //进行设置
        [button setAttributedTitle:[self attributeNormalTitleWithString:item] forState:UIControlStateNormal];
        [button setAttributedTitle:[self attributeSelectedTitleWithString:item] forState:UIControlStateSelected];
        
        button.backgroundColor = self.itemBackgroungColor;
        button.layer.cornerRadius = self.itemRadius;
        button.clipsToBounds = (self.itemRadius != 0);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)updateAllItemsAndViews
{
    [self updateAllItems];
}


#pragma mark - Getter


- (UIColor *)itemNormalColor
{
    return _itemNormalColor ? _itemNormalColor : UIColor.lightGrayColor;
}


- (UIColor *)itemSelectedColor
{
    return _itemSelectedColor ? _itemSelectedColor : UIColor.redColor;
}


- (UIColor *)itemBackgroungColor
{
    return _itemBackgroungColor ? _itemBackgroungColor : UIColor.clearColor;
}

- (UIFont *)itemNormalFont
{
    return _itemNormalFont ? _itemNormalFont : [UIFont systemFontOfSize:15];
}

- (UIFont *)itemSelectedFont
{
    return _itemSelectedFont ? _itemSelectedFont : self.itemNormalFont;
}

- (UIScrollView *)contentView
{
    if (!_contentView) {
        
        UIScrollView *scrollView = UIScrollView.new;
        scrollView.showsHorizontalScrollIndicator = false;
        [self addSubview:scrollView];
        _contentView = scrollView;
    }
    return _contentView;
}

- (UIImageView *)indicatorView
{
    if (!_indicatorView) {
        
        CGFloat indicatorH = self.indicatorHeight;
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.indicatorHeight - indicatorH, 0, indicatorH)];;
        [self.contentView addSubview:indicatorView];
        _indicatorView = indicatorView;
        
    }
    return _indicatorView;
}

@end



@implementation UIView (RITLSegmentBar)

- (void)setSeg_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)seg_centerX
{
    return self.center.x;
}

- (void)setSeg_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)seg_centerY
{
    return self.center.y;
}

- (void)setSeg_x:(CGFloat)x
{
    CGRect temp = self.frame;
    temp.origin.x = x;
    self.frame = temp;
}

- (CGFloat)seg_x
{
    return self.frame.origin.x;
}

- (void)setSeg_y:(CGFloat)y
{
    CGRect temp = self.frame;
    temp.origin.y = y;
    self.frame = temp;
}

- (CGFloat)seg_y
{
    return self.frame.origin.y;
}

- (void)setSeg_width:(CGFloat)width
{
    CGRect temp = self.frame;
    temp.size.width = width;
    self.frame = temp;
}

- (CGFloat)seg_width
{
    return self.frame.size.width;
}

- (void)setSeg_height:(CGFloat)height
{
    CGRect temp = self.frame;
    temp.size.height = height;
    self.frame = temp;
}

- (CGFloat)seg_height
{
    return self.frame.size.height;
}



@end
