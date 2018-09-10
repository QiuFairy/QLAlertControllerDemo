//
//  QLAlertTableViewCell.h
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/6.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//
/*!
 cell
 */
#import <UIKit/UIKit.h>
@class QLAlertAction;

@interface QLAlertTableViewCell : UITableViewCell
@property (nonatomic, strong) QLAlertAction *action;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *titleLabelConstraints;
@property (nonatomic, strong) NSMutableArray *lineConstraints;
@end
