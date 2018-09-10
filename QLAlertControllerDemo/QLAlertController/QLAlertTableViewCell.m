//
//  QLAlertTableViewCell.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/6.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "QLAlertTableViewCell.h"
#import "QLAlertAction.h"
#import "QLAlertConfig.h"

@implementation QLAlertTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        // 取消选中高亮
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [titleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [titleLabel sizeToFit];
        // footerCell指的是QLAlertControllerStyleActionSheet下的取消cell和QLAlertControllerStyleAlert下actions小于_maxNumberOfActionHorizontalArrangementForAlert时的cell
        // 这个cell因为要修改系统自带的布局，如果直接加在contentView上，修改contentView的布局很容易出问题，所以此时用不着contentView，而且这个cell跟tableView没有任何关系，就是一个普通的view
        if ([reuseIdentifier isEqualToString:FOOTERCELL]) {
            [self addSubview:titleLabel];
        } else {
            [self.contentView addSubview:titleLabel];
        }
        _titleLabel = titleLabel;
        
        _titleLabel.superview.backgroundColor = QL_NormalColor;
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setAction:(QLAlertAction *)action {
    _action = action;
    self.titleLabel.text = action.title;
    if (action.enabled) {
        self.titleLabel.textColor = action.titleColor;
        self.titleLabel.font = action.titleFont;
    } else {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    self.userInteractionEnabled = action.enabled;
    [self setNeedsUpdateConstraints];
}

// 默认走带动画的setHighlighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        // 高亮时设置contentView的白色0.2透明，如果用默认选中cell的样式或者直接设置self.selectedBackgroundView的颜色，则当cell高亮时分割线会跟着一起高亮， 分割线会看不见，所以只能对conntentView设置高亮，因为当有分割线存在时，contentView与cell之间上下是有间距的
        self.contentView.backgroundColor = QL_SelectedColor;
    } else {
        // 手指抬起时会来到这里
        self.backgroundColor = [UIColor clearColor];
        if (![self.reuseIdentifier isEqualToString:FOOTERCELL]) {
            self.contentView.backgroundColor = QL_NormalColor;
        } else {
            self.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
}


- (void)updateConstraints {
    [super updateConstraints];
    
    UILabel *titleLabel = self.titleLabel;
    
    if (self.titleLabelConstraints) {
        [titleLabel.superview removeConstraints:self.titleLabelConstraints];
        self.titleLabelConstraints = nil;
    }
    if (self.lineConstraints) {
        [self.contentView removeConstraints:self.lineConstraints];
        self.lineConstraints = nil;
    }
    
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleLabel.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(>=0)-[titleLabel]-(>=0)-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
    
    [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[titleLabel]-0-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
    [titleLabel.superview addConstraints:titleLabelConstraints];
    
    self.titleLabelConstraints = titleLabelConstraints;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
