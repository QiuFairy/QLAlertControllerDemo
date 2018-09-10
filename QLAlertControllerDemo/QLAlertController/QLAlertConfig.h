//
//  QLAlertConfig.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/6.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

/*!
 基础配置库
 */
#ifndef QLAlertConfig_h
#define QLAlertConfig_h

#define QL_ScreenWidth [UIScreen mainScreen].bounds.size.width
#define QL_ScreenHeight [UIScreen mainScreen].bounds.size.height

#define QL_ColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define QL_LineColor [[UIColor grayColor] colorWithAlphaComponent:0.25]

#define QL_NormalColor [[UIColor whiteColor] colorWithAlphaComponent:0.65]
#define QL_SelectedColor [UIColor colorWithWhite:1 alpha:0.2]

#define QL_ActionHeight 49.0
#define QL_LineWidth 0.5

#define QL_IsIPhoneX ([UIScreen mainScreen].bounds.size.height==812 || [UIScreen mainScreen].bounds.size.width==812)
#define QL_AlertBottomMargin (QL_IsIPhoneX ? 34 : 0) // 适配iPhoneX

static NSString * const FOOTERCELL = @"footerCell";

#endif /* QLAlertConfig_h */
