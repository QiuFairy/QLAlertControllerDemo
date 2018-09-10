//
//  QLAlertView.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

/*!
 alertview的主view，实现alert
 */
#import <UIKit/UIKit.h>
@class QLAlertAction;

@interface QLAlertView : UIView

typedef void(^QLAlertActionHandler)(QLAlertAction *alertBlockAction);

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


@property (nonatomic, strong, readonly) NSArray <QLAlertAction *>* _Nullable actions;

+ (instancetype _Nullable)alertViewWithFatherView:(UIView *)fatherView title:(nullable NSString *)title message:(nullable NSString *)message;

- (void)addAction:(QLAlertAction *_Nullable)action;

@property (nonatomic, copy, nullable) QLAlertActionHandler actionHandler;

@end
