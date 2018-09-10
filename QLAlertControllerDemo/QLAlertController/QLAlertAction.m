//
//  QLAlertAction.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "QLAlertAction.h"

@interface QLAlertAction()

@property (nullable, nonatomic) NSString *title;
@property (nonatomic, assign) QLAlertActionStyle style;
@end

@implementation QLAlertAction

- (id)copyWithZone:(NSZone *)zone {
    QLAlertAction *action = [[[self class] alloc] init];
    action.title = [self.title copy];
    action.style = self.style;
    action.enabled = self.enabled;
    action.titleColor = self.titleColor;
    action.titleFont = self.titleFont;
    action.handler = self.handler;
    return action;
}

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(QLAlertActionStyle)style handler:(void (^ __nullable)(QLAlertAction *action))handler {
    QLAlertAction *action = [[self alloc] initWithTitle:title style:(QLAlertActionStyle)style handler:handler];
    return action;
}

- (instancetype)initWithTitle:(nullable NSString *)title style:(QLAlertActionStyle)style handler:(void (^ __nullable)(QLAlertAction *action))handler {
    if (self = [super init]) {
        self.title = title;
        self.style = style;
        self.enabled = YES;
        self.handler = handler;
        if (style == QLAlertActionStyleDestructive) {
            self.titleColor = [UIColor redColor];
        } else if (style == QLAlertActionStyleCancel) {
            self.titleColor = [UIColor blueColor];
        } else {
            self.titleColor = [UIColor blackColor];
        }
    }
    return self;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.propertyEvent) {
        self.propertyEvent(self);
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if (self.propertyEvent) {
        self.propertyEvent(self);
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (self.propertyEvent) {
        self.propertyEvent(self);
    }
}
@end
