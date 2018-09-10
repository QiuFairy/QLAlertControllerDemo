//
//  QLActionSheetView.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

/*!
 alertsheet的主view，实现alertsheet
 */
#import <UIKit/UIKit.h>
@class QLAlertAction;

typedef void(^QLAlertActionHandler)(QLAlertAction *alertBlockAction);

@interface QLActionSheetView : UIView

/** 大标题 */
@property (nullable, nonatomic, copy) NSString *title;
/** 副标题 */
@property (nullable, nonatomic, copy) NSString *message;
/** 大标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;
/** 副标题颜色 */
@property (nonatomic, strong) UIColor *messageColor;
/** 大标题字体 */
@property (nonatomic, strong) UIFont *titleFont;
/** 副标题字体 */
@property (nonatomic, strong) UIFont *messageFont;

@property (nonatomic, strong, readonly) NSArray <QLAlertAction *>* _Nullable actions;

+ (instancetype _Nullable)actionSheetViewWithFatherView:(UIView *)fatherView title:(nullable NSString *)title message:(nullable NSString *)message;

- (void)addAction:(QLAlertAction *_Nullable)action;

@property (nonatomic, copy, nullable) QLAlertActionHandler actionHandler;

@end
