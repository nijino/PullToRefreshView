//
//  HeaderRefreshView.h
//  一个模仿系统下拉刷新的控件
//
//  Created by nijino on 14-8-21.
//  Copyright (c) 2014年 http://www.nijino.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderRefreshView : UIControl

@property (nonatomic, copy) NSString * normalString;//正常状态显示的字符串
@property (nonatomic, copy) NSString * releaseToRefreshString;//松手即可刷新显示的字符串
@property (nonatomic, copy) NSString * loadingString;//读取中显示的字符串
@property (nonatomic) UIColor *textColor;//提示语文字颜色

- (void)beginRefreshing;//开始刷新
- (void)endRefreshing;//结束刷新

@end
