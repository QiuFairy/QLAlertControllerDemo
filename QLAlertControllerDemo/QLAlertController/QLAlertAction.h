//
//  QLAlertAction.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

/*!
 此类为属性配置类，主要是配置一些基本属性，并且提供点击回传等功能
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QLAlertActionStyle) {
    QLAlertActionStyleDefault = 0, // 默认样式
    QLAlertActionStyleCancel,      // 取消样式
    QLAlertActionStyleDestructive  // 点击按钮为红色
};

@interface QLAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(QLAlertActionStyle)style handler:(void (^ __nullable)(QLAlertAction *action))handler;

/* 标题 */
@property (nullable, nonatomic, readonly) NSString *title;
/* 样式 */
@property (nonatomic, readonly) QLAlertActionStyle style;
/* 是否能点击,默认为YES,当为NO时，action的文字颜色为浅灰色，字体17号，且无法修改 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/* 标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;
/* 标题字体 */
@property (nonatomic, strong) UIFont *titleFont;

// 当在addAction之后设置action属性时,会回调这个block,设置相应控件的字体、颜色等
// 如果没有这个block，那使用时，只有在addAction之前设置action的属性才有效
@property (nonatomic, copy) void (^propertyEvent)(QLAlertAction *action);

@property (nonatomic, copy) void (^handler)(QLAlertAction *action);
@end
