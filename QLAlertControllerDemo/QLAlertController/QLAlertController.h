//
//  QLAlertController.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

/*!
 主vc，主要用来设置默认数据，及进行数据的分发
 */

#import <UIKit/UIKit.h>
#import "QLAlertAction.h"

typedef NS_ENUM(NSInteger, QLAlertControllerStyle) {
    QLAlertControllerStyleActionSheet = 0,
    QLAlertControllerStyleAlert
};

typedef NS_ENUM(NSInteger, QLAlertAnimationType) {
    QLAlertAnimationTypeDefault = 0, // 默认动画，如果是QLAlertControllerStyleActionSheet样式,默认动画等效于QLAlertAnimationTypeRaiseUp，如果是QLAlertControllerStyleAlert样式,默认动画等效于QLAlertAnimationTypeAlpha
    QLAlertAnimationTypeRaiseUp,     // 从下往上弹，一般用于actionSheet
    QLAlertAnimationTypeDropDown,    // 从上往下弹，一般用于actionSheet
    QLAlertAnimationTypeAlpha,       // 透明度从0到1，一般用于alert
    QLAlertAnimationTypeExpand,      // 发散动画，一般用于alert
    QLAlertAnimationTypeShrink       // 收缩动画，一般用于alert
};

@interface QLAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QLAlertControllerStyle)preferredStyle;

- (void)addAction:(QLAlertAction *)action;
@property (nonatomic, readonly) NSArray<QLAlertAction *> *actions;

@property (nonatomic, assign) QLAlertControllerStyle preferredStyle;

@property (nonatomic, assign) QLAlertAnimationType animationType;

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

/** alert样式下,水平排列的最大个数,如果大于了这个数,则所有action将垂直排列,默认是2. */
@property (nonatomic, assign) NSInteger maxNumberOfActionHorizontalArrangementForAlert;
/** 是否单击背景退出对话框,默认为YES */
@property (nonatomic, assign) BOOL tapBackgroundViewDismiss;

@end
