//
//  QLAlertAnimation.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/6.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

/*!
 Animation
 */
#import <UIKit/UIKit.h>

@interface QLAlertAnimation : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)animationIsPresenting:(BOOL)presenting;
@end
