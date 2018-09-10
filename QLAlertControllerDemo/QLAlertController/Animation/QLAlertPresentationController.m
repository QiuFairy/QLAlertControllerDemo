//
//  QLAlertPresentationController.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/6.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "QLAlertPresentationController.h"
#import "QLAlertController.h"
#import "QLAlertConfig.h"

@interface QLAlertPresentationController()

@property (nonatomic, strong) NSMutableArray *presentedViewConstraints;
@end

@implementation QLAlertPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        self.presentedView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}
- (void)willChangeStatusBarOrientation:(NSNotification *)notification {
    [self.overlayView setNeedsDisplay];
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification {
    
    // 延迟0.3秒再镂空,之所以延迟，是因为实际上界面还没有最终切换到肉眼所看到的横(竖)屏,就开始走这个方法,也就意味着界面还没有旋转停止下来就开始镂空，这样又可以看到镂出来的洞
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        QLAlertController *alertController = (QLAlertController *)self.presentedViewController;
        CGFloat cornerRadius = 0;
        if (alertController.preferredStyle == QLAlertControllerStyleAlert) {
            cornerRadius = 10;
        }
    });
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    if (!self.presentedView.superview) {
        return;
    }
    [self updateConstraints];
}

- (void)containerViewDidLayoutSubviews {
    [super containerViewDidLayoutSubviews];
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    QLAlertController *alertController = (QLAlertController *)self.presentedViewController;
    
    UIView *overlayView = [[UIView alloc] init];
    overlayView.frame = self.containerView.bounds;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    overlayView.alpha = 0;
    [self.containerView addSubview:overlayView];
    _overlayView = overlayView;
    
    if (alertController.tapBackgroundViewDismiss) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOverlayView)];
        [_overlayView addGestureRecognizer:tap];
    }
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    if (completed) {
        [_overlayView removeFromSuperview];
        _overlayView = nil;
    }
}

- (CGRect)frameOfPresentedViewInContainerView{
    return self.presentedView.frame;
}

// 这不是系统的方法
- (void)updateConstraints {
    QLAlertController *alertController = (QLAlertController *)self.presentedViewController;
    CGFloat maxTopMarginForActionSheet = QL_IsIPhoneX ? 44 : 0;
    CGFloat maxMarginForAlert = 20;
    CGFloat topMarginForAlert = QL_IsIPhoneX ? (maxMarginForAlert+44):maxMarginForAlert;
    CGFloat bottomMarginForAlert = QL_IsIPhoneX ? (maxMarginForAlert+34):maxMarginForAlert;
    
    UIView *presentedView = self.presentedView;
    
    NSMutableArray *presentedViewConstraints = [NSMutableArray array];
    if (self.presentedViewConstraints) {
        [self.containerView removeConstraints:self.presentedViewConstraints];
        self.presentedViewConstraints = nil;
    }
    if (alertController.preferredStyle == QLAlertControllerStyleActionSheet) {
        [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:QL_ScreenWidth]];
        [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        if (alertController.animationType == QLAlertAnimationTypeDropDown) {
            [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==maxTopMarginForActionSheet)-[presentedView]-(>=alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(QL_AlertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
        } else {
            [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxTopMarginForActionSheet)-[presentedView]-(==alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(QL_AlertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
        }
    } else if (alertController.preferredStyle == QLAlertControllerStyleAlert) {
        [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(MIN(QL_ScreenWidth, QL_ScreenHeight)-2*maxMarginForAlert)]];
        [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        NSLayoutConstraint *topConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:topMarginForAlert];
        // 这个地方给一个优先级是为了给垂直中心的y值让步,假如垂直中心y达到某一个值的时候(特别是有文本输入框时，旋转到横屏后，留给对话框的控件比较小)，以至于对话框的顶部或底部间距小于了topMarginForAlert，此时便会有约束冲突
        topConstraints.priority = 999.f;
        [presentedViewConstraints addObject:topConstraints];
        NSLayoutConstraint *bottomConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-bottomMarginForAlert];
        [presentedViewConstraints addObject:bottomConstraints];
        NSLayoutConstraint *centerYConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        [presentedViewConstraints addObject:centerYConstraints];
    }
    [self.containerView addConstraints:presentedViewConstraints];
    
    self.presentedViewConstraints = presentedViewConstraints;
}

- (void)tapOverlayView {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
