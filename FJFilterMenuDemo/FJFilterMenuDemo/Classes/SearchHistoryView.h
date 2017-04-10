//
//  SearchHistoryView.h
//  FJFilterMenuDemo
//
//  Created by Jeff on 2017/4/7.
//  Copyright © 2017年 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchHistoryView : UIView

@property (nonatomic, copy) void(^tagTapped)(NSString *tag);
@property (nonatomic, copy) void(^tagScrolled)(void);

- (void)refresh:(BOOL)hotSearch;

@end
