//
//  HeaderRefreshView.m
//  一个模仿系统下拉刷新的控件
//
//  Created by nijino on 14-8-21.
//  Copyright (c) 2014年 http://www.nijino.cn. All rights reserved.
//

#import "HeaderRefreshView.h"
@import QuartzCore;

static const int distanceForTriggerRefresh = 75;//触发刷新下拉距离
static const int offsetInRefreshing = 40;//刷新中偏移量

typedef NS_ENUM(NSUInteger, RefreshState) {
    RefreshStateNormal,//一般状态
    RefreshStatePulling,//松手可刷新
    RefreshStateLoading,//刷新中
};

@interface HeaderRefreshView ()

@property (nonatomic) UILabel *statusLabel;//状态Label
@property (nonatomic) CAShapeLayer *pullProgressLayer;//下拉进度随动层
@property (nonatomic) CAShapeLayer *loadingLayer;//读取中转圈层
@property (nonatomic) RefreshState refreshState;//状态枚举值
@property (nonatomic) BOOL isLoading;//是否在读取中

@end

@implementation HeaderRefreshView

- (void)setup{
    _normalString = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
    _releaseToRefreshString = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
    _loadingString = NSLocalizedString(@"Loading...", @"Loading Status");
    self.backgroundColor = [UIColor colorWithRed:242./255 green:242./255 blue:242./255 alpha:1];
    _textColor = [UIColor colorWithRed:100./255 green:107./255 blue:103./255 alpha:1];
}


- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

//画圆圈形状
- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:- M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:NO];
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    return slice;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    self.frame = CGRectMake(0, - CGRectGetHeight(newSuperview.frame), CGRectGetWidth(newSuperview.frame), CGRectGetHeight(newSuperview.frame));
        
    //状态标签
    CGRect statusLabelRect = CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 20.0f);
    UILabel *label = [[UILabel alloc] initWithFrame:statusLabelRect];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.textColor = self.textColor;
    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.normalString;
    [self addSubview:label];
    self.statusLabel = label;
    
    //下拉进度
    self.pullProgressLayer = [self createRingLayerWithCenter:CGPointMake(80, self.frame.size.height - 20.0f) radius:8 lineWidth:2 color:[UIColor colorWithRed:100./255 green:107./255 blue:103./255 alpha:1]];
    self.pullProgressLayer.strokeEnd = 0;
    [self.layer addSublayer:self.pullProgressLayer];
    
    //读取层，读取中显示旋转动画
    self.loadingLayer = [self createRingLayerWithCenter:CGPointMake(80, self.frame.size.height - 20.0f) radius:8 lineWidth:2 color:[UIColor colorWithRed:100./255 green:107./255 blue:103./255 alpha:1]];
    self.loadingLayer.strokeEnd = 0.9;
    self.loadingLayer.hidden = YES;
    [self.layer addSublayer:self.loadingLayer];
    
    //对superView的contentOffset属性进行监听
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    UIScrollView *scrollView;
    if ([object isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)object;
    }
    if (self.refreshState == RefreshStateLoading) {
        CGFloat offset = MAX(scrollView.contentOffset.y * - 1, 0);
        offset = MIN(offset, offsetInRefreshing);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        self.pullProgressLayer.strokeEnd = 0;
    } else if (scrollView.isDragging) {
        if (self.refreshState == RefreshStatePulling
            && scrollView.contentOffset.y > - distanceForTriggerRefresh
            && scrollView.contentOffset.y < 0
            && !self.isLoading) {
            self.refreshState = RefreshStateNormal;
        }
        if (self.refreshState == RefreshStateNormal
            && scrollView.contentOffset.y < - distanceForTriggerRefresh
            && !self.isLoading) {
            self.refreshState = RefreshStatePulling;
        }
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        self.pullProgressLayer.strokeEnd = - scrollView.contentOffset.y / (distanceForTriggerRefresh + 10);
    } else if (!scrollView.isDragging){
        if (scrollView.contentOffset.y <= - (distanceForTriggerRefresh - 25)
            && !self.isLoading
            && self.refreshState != RefreshStateNormal) {
            [self beginRefreshing];
        }
    }
}

//无限旋转
- (void)rotateLoadingLayer{
    CABasicAnimation* rotationAnimation =
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];//"z"还可以是“x”“y”，表示沿z轴旋转
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * 3];
    rotationAnimation.duration = 2.f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.repeatCount = NSIntegerMax;
    [self.loadingLayer addAnimation:rotationAnimation forKey:@"rotate"];
}


- (void)setRefreshState:(RefreshState)refreshState{
    switch (refreshState) {
		case RefreshStatePulling:
			self.statusLabel.text = self.releaseToRefreshString;
			break;
		case RefreshStateNormal:
			self.pullProgressLayer.hidden = NO;
			self.statusLabel.text = self.normalString;
            self.loadingLayer.hidden = YES;
            [self.loadingLayer removeAllAnimations];
			break;
		case RefreshStateLoading:
			self.statusLabel.text = self.loadingString;
            self.loadingLayer.hidden = NO;
            [self rotateLoadingLayer];
			break;
		default:
			break;
	}
	_refreshState = refreshState;
}

- (void)beginRefreshing{
    if (!self.isLoading) {
        if (self.allTargets.count) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            self.isLoading = YES;
            self.refreshState = RefreshStateLoading;
            if ([self.superview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)self.superview;
                [UIView animateWithDuration:.2 animations:^{
                    scrollView.contentInset = UIEdgeInsetsMake(offsetInRefreshing, 0, 0, 0);
                }];
            }
        }
    }
}

- (void)endRefreshing{
    self.isLoading = NO;
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        [UIView animateWithDuration:.3 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }];
        self.refreshState = RefreshStateNormal;
    }
}

@end