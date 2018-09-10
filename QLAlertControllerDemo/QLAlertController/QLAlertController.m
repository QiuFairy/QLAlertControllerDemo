//
//  QLAlertController.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "QLAlertController.h"
#import "QLAlertConfig.h"

//分view
#import "QLAlertView.h"
#import "QLActionSheetView.h"

//动画
#import "QLAlertPresentationController.h"
#import "QLAlertAnimation.h"

@interface QLAlertController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) QLAlertView *alertView; //alertView
@property (nonatomic, weak) QLActionSheetView *actionSheetView; //actionSheetView

@end

@implementation QLAlertController
@synthesize title = _title;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Public
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QLAlertControllerStyle)preferredStyle{
    
    QLAlertController *alertController = [self alertControllerWithTitle:title message:message preferredStyle:preferredStyle animationType:QLAlertAnimationTypeDefault customView:nil];
    
    return alertController;
}
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QLAlertControllerStyle)preferredStyle animationType:(QLAlertAnimationType)animationType customView:(UIView *)customView {
    // 创建控制器
    QLAlertController *alertController = [[QLAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:customView];
    return alertController;
}
#pragma mark - Private
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QLAlertControllerStyle)preferredStyle animationType:(QLAlertAnimationType)animationType customView:(UIView *)customView{
    if (self = [super init]) {
        
        // 是否视图控制器定义它呈现视图控制器的过渡风格（默认为NO）
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        
        _title = title;
        _message = message;
        self.preferredStyle = preferredStyle;
        // 如果是默认动画，preferredStyle为alert时动画默认为fade，preferredStyle为actionShee时动画默认为raiseUp
        if (animationType == QLAlertAnimationTypeDefault) {
            if (self.preferredStyle == QLAlertControllerStyleAlert) {
                animationType= QLAlertAnimationTypeAlpha;
            } else if (self.preferredStyle == QLAlertControllerStyleActionSheet) {
                animationType = QLAlertAnimationTypeRaiseUp;
            }
        }
        //default set
        self.maxNumberOfActionHorizontalArrangementForAlert = 2;
        
        //这里面划分各种情况
        if (self.preferredStyle == QLAlertControllerStyleAlert) {
            self.tapBackgroundViewDismiss = NO;
            QLAlertView *alertView = [QLAlertView alertViewWithFatherView:self.view title:self.title message:self.message];
            alertView.maxNumberOfActionHorizontalArrangementForAlert = self.maxNumberOfActionHorizontalArrangementForAlert;
            alertView.actionHandler = ^(QLAlertAction *alertBlockAction) {
                // 回调action的block
                if (alertBlockAction.handler) {
                    alertBlockAction.handler(alertBlockAction);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            [self.view addSubview:alertView];
            _alertView = alertView;
        }else if (self.preferredStyle == QLAlertControllerStyleActionSheet) {
            self.tapBackgroundViewDismiss = YES;
            QLActionSheetView *actionSheetView = [QLActionSheetView actionSheetViewWithFatherView:self.view title:self.title message:self.message];
            actionSheetView.actionHandler = ^(QLAlertAction *alertBlockAction) {
                // 回调action的block
                if (alertBlockAction.handler) {
                    alertBlockAction.handler(alertBlockAction);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            [self.view addSubview:actionSheetView];
            _actionSheetView = actionSheetView;
        }
        
        self.animationType = animationType;
    }
    return self;
}
// 添加action
- (void)addAction:(QLAlertAction *)action {
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        [self.alertView addAction:action];
    }else{
        [self.actionSheetView addAction:action];
    }
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        self.alertView.title = title;
    }else if (self.preferredStyle == QLAlertControllerStyleActionSheet){
        self.actionSheetView.title = title;
    }
}
- (void)setMessage:(NSString *)message {
    _message = [message copy];
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        self.alertView.message = message;
    }else if (self.preferredStyle == QLAlertControllerStyleActionSheet){
        self.actionSheetView.message = message;
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        self.alertView.titleColor = titleColor;
    }else if (self.preferredStyle == QLAlertControllerStyleActionSheet){
        self.actionSheetView.titleColor = titleColor;
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        self.alertView.titleFont = titleFont;
    }else if (self.preferredStyle == QLAlertControllerStyleActionSheet){
        self.actionSheetView.titleFont = titleFont;
    }
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        self.alertView.messageColor = messageColor;
    }else if (self.preferredStyle == QLAlertControllerStyleActionSheet){
        self.actionSheetView.messageColor = messageColor;
    }
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    if (self.preferredStyle == QLAlertControllerStyleAlert) {
        self.alertView.messageFont = messageFont;
    }else if (self.preferredStyle == QLAlertControllerStyleActionSheet){
        self.actionSheetView.messageFont = messageFont;
    }
}
- (void)setMaxNumberOfActionHorizontalArrangementForAlert:(NSInteger)maxNumberOfActionHorizontalArrangementForAlert {
    _maxNumberOfActionHorizontalArrangementForAlert = maxNumberOfActionHorizontalArrangementForAlert;
    self.alertView.maxNumberOfActionHorizontalArrangementForAlert = maxNumberOfActionHorizontalArrangementForAlert;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [QLAlertAnimation animationIsPresenting:YES];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self.view endEditing:YES];
    return [QLAlertAnimation animationIsPresenting:NO];
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0) {
    return [[QLAlertPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
