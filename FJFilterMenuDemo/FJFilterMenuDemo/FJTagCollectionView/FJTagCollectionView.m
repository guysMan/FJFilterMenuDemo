//
//  FJTagCollectionView.m
//  FJFilterMenuDemo
//
//  Created by Jeff on 2017/4/7.
//  Copyright © 2017年 Jeff. All rights reserved.
//

#import "FJTagCollectionView.h"
#import "FJTagConfig.h"
#import "FJTextButton.h"
#import "FJTagModel.h"
#import "NSArray+FJTagModel.h"
#import <FJTool/FJTool.h>
#import <BlocksKit/BlocksKit+UIKit.h>

#define DefaultHeight (20.0)

@interface FJTagCollectionView()

@property (nonatomic, strong) FJTagConfig *innerTagConfig;
@property (nonatomic, strong) NSMutableArray<FJTagModel *> *innerTags;
@property (nonatomic, strong) NSArray<FJTagModel *> *innerSelectedTags;
@property (nonatomic, assign) CGFloat innerWidth;


@end


@implementation FJTagCollectionView

- (NSMutableArray<FJTagModel *> *)innerTags {
    if (_innerTags == nil) {
        _innerTags = (NSMutableArray<FJTagModel *> *)[[NSMutableArray alloc] init];
    }
    return _innerTags;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

// 添加Tags
- (void)addTags:(NSArray<FJTagModel *> *)tags {
    [self addTags:tags config:nil];
}

// 添加Tags(Config)
- (void)addTags:(NSArray<FJTagModel *> *)tags config:(FJTagConfig*)config {
    [self addTags:tags config:config selectedTags:nil];
}

// 添加Tags(Config, SelectedTags)
- (void)addTags:(NSArray<FJTagModel *> *)tags config:(FJTagConfig*)config selectedTags:(NSArray<FJTagModel *> *)selectedTags {
    if (tags == nil || [tags count] == 0) {
        return;
    }
    
    [self.innerTags addObjectsFromArray:tags];
    self.innerSelectedTags = selectedTags;
    if (config != nil) {
        self.innerTagConfig = config;
    }
}

// 插入Tags
// 插入Tags
- (void)insertTag:(FJTagModel *)tag atIndex:(NSUInteger)index {
    [self insertTag:tag atIndex:index config:nil];
}

// 插入Tags(Config)
- (void)insertTag:(FJTagModel *)tag atIndex:(NSUInteger)index config:(FJTagConfig*)config {
    [_innerTags insertObject:tag atIndex:index];
    if (config != nil) {
        self.innerTagConfig = config;
    }
}

// 删除Tags(名称)
- (void)removeTag:(FJTagModel *)tag {
    [_innerTags removeObject:tag];
}

// 删除Tags(Index)
- (void)removeTagAt:(NSUInteger)index {
    [_innerTags removeObjectAtIndex:index];
}

// 删除所有Tags
- (void)removeAllTags {
    [_innerTags removeAllObjects];
}

// 设置Tag View的Origin位置
- (void)setTagViewOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

// 设置Tag View的宽
- (void)setTagViewWidth:(CGFloat)width {
    self.innerWidth = width;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, DefaultHeight);
}

// 更新Tag View的高
- (void)updateTagViewHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
}

// 获取TagCollectionView的大小
- (CGSize)getTagViewSize {
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

// 获取所有Tags
- (NSArray<FJTagModel *> *)allTags {
    return _innerTags;
}

// 刷新UI
- (void)refresh {
    
    NSAssert(self.innerWidth >= 1.0, @"控件必须有一个宽度或高度");
    
    if (_innerTagConfig == nil) {
        self.innerTagConfig = [[FJTagConfig alloc] init];
    }
    
    // Clear UI
    for (UIButton *tagButton in [self subviews]) {
        [tagButton removeFromSuperview];
    }
    
    CGFloat orgX = _innerTagConfig.paddingLeft;
    CGFloat orgY = _innerTagConfig.paddingTop;
    CGFloat endX = self.innerWidth - _innerTagConfig.paddingRight;
    CGFloat eachX = orgX;
    CGFloat eachY = orgY;
    for (FJTagModel *tag in self.innerTags) {

        FJTextButton *btn = [self tagButton:tag];
        if (btn.width + eachX > endX) {
            // 换行
            eachX = orgX;
            eachY = eachY + btn.bounds.size.height + _innerTagConfig.itemVerticalSpace;
            btn.origin = CGPointMake(eachX, eachY);
        }else{
            // 不换行
            btn.origin = CGPointMake(eachX, eachY);
        }
        [self addSubview:btn];
        eachX += btn.bounds.size.width + _innerTagConfig.itemHorizontalSpace;
    }
    [self updateTagViewHeight:(eachY + _innerTagConfig.itemMinHeight + _innerTagConfig.paddingBottom)];
    
    
    // Debug
    if (_innerTagConfig.debug) {
        self.backgroundColor = self.backgroundColor = COLOR_TEXT_GREEN;
        
        UIView * v = [[UIView alloc] initWithFrame:CGRectMake(_innerTagConfig.paddingLeft, _innerTagConfig.paddingTop, self.bounds.size.width - _innerTagConfig.paddingLeft - _innerTagConfig.paddingRight, self.bounds.size.height - _innerTagConfig.paddingTop - _innerTagConfig.paddingBottom)];
        [self insertSubview:v atIndex:0];
        v.backgroundColor = COLOR_TEXT_BLUE;
        
    }
}

- (FJTextButton*)tagButton:(FJTagModel *)tagModel {
    
    FJTextButton *button = [[FJTextButton alloc] initWithFrame:CGRectMake(0, 0, _innerTagConfig.itemMinWidth, _innerTagConfig.itemMinHeight)];
    button.tagModel = tagModel;
    if (self.innerSelectedTags == nil || [self.innerSelectedTags count] == 0 || ![self.innerSelectedTags containsTagModel:tagModel]) {
        [button setTitle:[tagModel tag] config:_innerTagConfig selected:NO];
    }else{
        [button setTitle:[tagModel tag] config:_innerTagConfig selected:YES];
    }

    CGFloat textWidth = [[tagModel tag] singleWidthWithLabelFont:_innerTagConfig.tagTextFont enableCeil:YES];
    CGFloat buttonWidth = textWidth + _innerTagConfig.itemPaddingLeft + _innerTagConfig.itemPaddingRight;
    if (buttonWidth >= self.innerWidth - _innerTagConfig.paddingLeft - _innerTagConfig.paddingRight) {
        button.width = self.innerWidth - _innerTagConfig.paddingLeft - _innerTagConfig.paddingRight;
    }else if (buttonWidth >= _innerTagConfig.itemMinWidth) {
        button.width = buttonWidth;
    }else {
        button.width = _innerTagConfig.itemMinWidth;
    }
    
//    if (_innerTagConfig.selectedImageSize.width > 0) {
//        button.titleEdgeInsets = UIEdgeInsetsMake(0, _innerTagConfig.selectedImageSize.width, 0, 0);
//    }
    
    MF_WEAK_SELF(self);
    [button bk_addEventHandler:^(FJTextButton *sender) {
        if (_innerTagConfig.enableMultiTap) {
            weakSelf.tagMultiTappedBlock == nil ? : weakSelf.tagMultiTappedBlock(sender.tagModel, [(FJTextButton*)sender selected]);
        }else{
            weakSelf.tagTappedBlock == nil ? : weakSelf.tagTappedBlock(sender.tagModel);
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 计算控件高度
+ (CGSize)calculateSize:(CGFloat)width tags:(NSArray<FJTagModel *> *)tags config:(FJTagConfig*)config {
    
    CGFloat orgX = config.paddingLeft;
    CGFloat orgY = config.paddingTop;
    CGFloat endX = width - config.paddingRight;
    CGFloat eachX = orgX;
    CGFloat eachY = orgY;
    for (FJTagModel *tag in tags) {
        
        CGFloat textWidth = [[tag tag] singleWidthWithLabelFont:config.tagTextFont enableCeil:YES];
        CGFloat buttonWidth = textWidth + config.itemPaddingLeft + config.itemPaddingRight;
        if (buttonWidth >= width) {
            buttonWidth = width - config.paddingLeft - config.paddingRight - 1.0;
        }else if (buttonWidth >= config.itemMinWidth) {
            
        }else {
            buttonWidth = config.itemMinWidth;
        }
        
        if (buttonWidth + eachX > endX) {
            // 换行
            eachX = orgX;
            eachY = eachY + config.itemMinHeight + config.itemVerticalSpace;
        }else{
            // 不换行
        }
        eachX += buttonWidth + config.itemHorizontalSpace;
    }
    return CGSizeMake(width, (eachY + config.itemMinHeight + config.paddingBottom));
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
