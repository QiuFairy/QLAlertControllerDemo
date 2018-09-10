//
//  QLAlertAnimation.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/6.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "QLAlertAnimation.h"
#import "QLAlertController.h"
#import "QLAlertPresentationController.h"
#import "QLAlertConfig.h"

@interface QLAlertAnimation()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation QLAlertAnimation
- (instancetype)initWithPresenting:(BOOL)isPresenting {
    if (self = [super init]) {
        self.presenting = isPresenting;
    }
    return self;
}

+ (instancetype)animationIsPresenting:(BOOL)isPresenting {
    return [[self alloc] initWithPresenting:isPresenting];
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        return 0.3f;
    } else {
        return 0.3f;
    }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self presentAnimationTransition:transitionContext];
    } else {
        [self dismissAnimationTransition:transitionContext];
    }
}

- (void)presentAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    QLAlertController *alertController = (QLAlertController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGSize controlViewSize = alertController.view.bounds.size;
    
    // 获取presentationController，注意不是presentedController
    QLAlertPresentationController *presentedController = (QLAlertPresentationController *)alertController.presentationController;
    UIView *overlayView = presentedController.overlayView;
    
    switch (alertController.animationType) {
        case QLAlertAnimationTypeRaiseUp:
            [self raiseUpWhenPresentForController:alertController
                                       transition:transitionContext
                                  controlViewSize:controlViewSize
                                      overlayView:overlayView];
            break;
        case QLAlertAnimationTypeDropDown:
            [self dropDownWhenPresentForController:alertController
                                        transition:transitionContext
                                   controlViewSize:controlViewSize
                                       overlayView:overlayView];
            
            break;
        case QLAlertAnimationTypeAlpha:
            [self alphaWhenPresentForController:alertController
                                     transition:transitionContext
                                controlViewSize:controlViewSize
                                    overlayView:overlayView];
            break;
        case QLAlertAnimationTypeExpand:
            [self expandWhenPresentForController:alertController
                                      transition:transitionContext
                                 controlViewSize:controlViewSize
                                     overlayView:overlayView];
            break;
        case QLAlertAnimationTypeShrink:
            [self shrinkWhenPresentForController:alertController
                                      transition:transitionContext
                                 controlViewSize:controlViewSize
                                     overlayView:overlayView];
            break;
        default:
            break;
    }
    
}

- (void)dismissAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    QLAlertController *alertController = (QLAlertController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGSize controlViewSize = alertController.view.bounds.size;
    // 获取presentationController，注意不是presentedController
    QLAlertPresentationController *presentedController = (QLAlertPresentationController *)alertController.presentationController;
    UIView *overlayView = presentedController.overlayView;
    
    switch (alertController.animationType) {
        case QLAlertAnimationTypeRaiseUp:
            [self dismissCorrespondingRaiseUpForController:alertController
                                                transition:transitionContext
                                           controlViewSize:controlViewSize
                                               overlayView:overlayView];
            break;
        case QLAlertAnimationTypeDropDown:
            [self dismissCorrespondingDropDownForController:alertController
                                                 transition:transitionContext
                                            controlViewSize:controlViewSize
                                                overlayView:overlayView];
            break;
            
        case QLAlertAnimationTypeAlpha:
            [self dismissCorrespondingAlphaForController:alertController
                                              transition:transitionContext
                                         controlViewSize:controlViewSize
                                             overlayView:overlayView];
            break;
        case QLAlertAnimationTypeExpand:
            [self dismissCorrespondingExpandForController:alertController
                                               transition:transitionContext
                                          controlViewSize:controlViewSize
                                              overlayView:overlayView];
            break;
        case QLAlertAnimationTypeShrink:
            [self dismissCorrespondingShrinkForController:alertController
                                               transition:transitionContext
                                          controlViewSize:controlViewSize
                                              overlayView:overlayView];
            break;
        default:
            break;
    }
    
}

// 从底部忘上弹的present动画
- (void)raiseUpWhenPresentForController:(QLAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        controlViewSize:(CGSize)controlViewSize
                            overlayView:(UIView *)overlayView {
    
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = QL_ScreenHeight;
    alertController.view.frame = controlViewFrame;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = QL_ScreenHeight-controlViewSize.height-QL_AlertBottomMargin;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}
// 从底部往上弹对应的dismiss动画
- (void)dismissCorrespondingRaiseUpForController:(QLAlertController *)alertController
                                      transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                 controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = QL_ScreenHeight;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 从顶部往下弹的present动画
- (void)dropDownWhenPresentForController:(QLAlertController *)alertController
                              transition:(id<UIViewControllerContextTransitioning>)transitionContext
                         controlViewSize:(CGSize)controlViewSize
                             overlayView:(UIView *)overlayView {
    
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = -controlViewSize.height;
    alertController.view.frame = controlViewFrame;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = QL_IsIPhoneX ? 44 : 0;;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}
// 从顶部往下弹对应的dismiss动画
- (void)dismissCorrespondingDropDownForController:(QLAlertController *)alertController
                                       transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                  controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = -controlViewSize.height;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// alpha值从0到1变化的present动画
- (void)alphaWhenPresentForController:(QLAlertController *)alertController
                           transition:(id<UIViewControllerContextTransitioning>)transitionContext
                      controlViewSize:(CGSize)controlViewSize
                          overlayView:(UIView *)overlayView {
    
    alertController.view.alpha = 0;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.alpha = 1;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}
// alpha值从0到1变化对应的的dismiss动画
- (void)dismissCorrespondingAlphaForController:(QLAlertController *)alertController
                                    transition:(id<UIViewControllerContextTransitioning>)transitionContext
                               controlViewSize:(CGSize)controlViewSize
                                   overlayView:(UIView *)overlayView {
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.alpha = 0;
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 发散的prensent动画
- (void)expandWhenPresentForController:(QLAlertController *)alertController
                            transition:(id<UIViewControllerContextTransitioning>)transitionContext
                       controlViewSize:(CGSize)controlViewSize
                           overlayView:(UIView *)overlayView {
    
    alertController.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:20 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}
// 发散对应的dismiss动画
- (void)dismissCorrespondingExpandForController:(QLAlertController *)alertController
                                     transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformMakeScale(0, 0);
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 收缩的present动画
- (void)shrinkWhenPresentForController:(QLAlertController *)alertController
                            transition:(id<UIViewControllerContextTransitioning>)transitionContext
                       controlViewSize:(CGSize)controlViewSize
                           overlayView:(UIView *)overlayView {
    
    alertController.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 收缩对应的的dismiss动画
- (void)dismissCorrespondingShrinkForController:(QLAlertController *)alertController
                                     transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    // 与发散对应的dismiss动画相同
    [self dismissCorrespondingExpandForController:alertController transition:transitionContext controlViewSize:controlViewSize overlayView:overlayView ];
}
@end
