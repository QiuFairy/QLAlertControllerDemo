//
//  QLActionSheetView.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "QLActionSheetView.h"
#import "QLAlertAction.h"
#import "QLAlertConfig.h"
#import "QLAlertTableViewCell.h"

@interface QLActionSheetView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong, readwrite) NSArray <QLAlertAction *> *actions;
//style == cancel 的所有按钮 注：一般只会设置一个
@property (nonatomic, strong) NSMutableArray <QLAlertAction *> *cancelActions;
// tableView的数据源,与actions数组息息相关
@property (nonatomic, strong) NSArray *dataSource;
// 底部的cell数组
@property (nonatomic, strong) NSMutableArray *footerCells;
// 底部的cell之间的分割线数组
@property (nonatomic, strong) NSMutableArray *footerLines;

// ---------------- 关于头部控件 ---------------
@property (nonatomic, weak) UIView *headerBezelView;
@property (nonatomic, weak) UIScrollView *headerScrollView;
@property (nonatomic, weak) UIView *headerScrollContentView; // autoLayout中需要在scrollView上再加一个view
@property (nonatomic, weak) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailTitleLabel;
@property (nonatomic, weak) UIView *headerActionLine;

// ---------------- 关于头部控件的约束数组 -----------------
@property (nonatomic, strong) NSMutableArray *headerBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerScrollContentViewConstraints;
@property (nonatomic, strong) NSMutableArray *titleViewConstraints;
@property (nonatomic, strong) NSMutableArray *titleLabelConstraints;
@property (nonatomic, strong) NSMutableArray *headerActionLineConstraints;

// ---------------- 关于action控件 --------------
@property (nonatomic, weak) UIView *actionBezelView;
@property (nonatomic, weak) UIView *actionCenterView;
@property (nonatomic, weak) UITableView *actionTableView;
@property (nonatomic, weak) UIView *footerBezelView;
@property (nonatomic, weak) UIView *footerTopLine;

// ---------------- 关于action控件的约束数组 -------------------
@property (nonatomic, strong) NSMutableArray *actionBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *actionCenterViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerCellConstraints;
@property (nonatomic, strong) NSMutableArray *footerTopLineConstraints;

@end

@implementation QLActionSheetView

+ (instancetype _Nullable)actionSheetViewWithFatherView:(UIView *)fatherView title:(nullable NSString *)title message:(nullable NSString *)message{
    QLActionSheetView *actionSheetView = [[QLActionSheetView alloc] initWithFrame:fatherView.frame];
    actionSheetView.title = title;
    actionSheetView.message = message;
    return actionSheetView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self configureProperties];
        [self createUI];
    }
    return self;
}
- (void)configureProperties{
    //设置圆角
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
//修改数据源
- (void)addAction:(QLAlertAction *)action{
    
    if ([self.actions containsObject:action]) {
        return;
    }
    
    NSMutableArray *array = self.actions.mutableCopy;
    // 一般来说取消样式的按钮不会太多,这里限制最多只能有5个取消样式的按钮
    NSAssert(self.cancelActions.count < 5, @"取消样式的按钮最多只能有5个");

    if (self.cancelActions.count ) {
        if (action.style == QLAlertActionStyleCancel) { // 取消样式的按钮顺序排列
            [array addObject:action];
        } else {
            NSInteger index = [self.actions indexOfObject:self.cancelActions.firstObject];
            // 普通按钮插入取消样式按钮之前
            [array insertObject:action atIndex:index];
        }
    } else {
        [array addObject:action];
    }
    self.actions = array;
    
    if (action.style == QLAlertActionStyleCancel) {
        [self.cancelActions addObject:action];
        [self createFooterCellWithAction:action];
    }
    self.dataSource = self.cancelActions.count ? [array subarrayWithRange:NSMakeRange(0, array.count-self.cancelActions.count)].copy : array.copy;
    
    __weak typeof(self) weakSelf = self;
    // 当外面在addAction之后再设置action的属性时，会回调这个block
    action.propertyEvent = ^(QLAlertAction *action) {
        if (action.style == QLAlertActionStyleCancel) {
            NSInteger index = [weakSelf.cancelActions indexOfObject:action];
            // 注意这个cell是与tableView没有任何瓜葛的
            QLAlertTableViewCell *footerCell = [weakSelf.footerCells objectAtIndex:index];
            footerCell.action = action;
        } else {
            // 刷新tableView
            [weakSelf.actionTableView reloadData];
        }
    };
    // 刷新tableView
    [self.actionTableView reloadData];
    
    [self layoutViewConstraints];
}
#pragma mark - UI
-(void)createUI{
    // 创建关于头部的子控件
    [self setupViewsOboutHeader];
    
    // 创建头部和actionBezelView之间的分割线
    [self setupHeaderActionLine];
    
    // 创建关于普通action的子控件
    [self setupViewsAboutAction];
    
    // 创建footerView顶部分割线，这条分割线就是将普通样式的action和取消样式的action隔开
    [self setupVFooterTopLine];
    
    // 创建footerView
    [self setupFooterView];
    [self layoutViewConstraints];
}
- (void)setupViewsOboutHeader {
    UIView *headerBezelView = [[UIView alloc] init];
    headerBezelView.translatesAutoresizingMaskIntoConstraints = NO;
    headerBezelView.backgroundColor = QL_NormalColor;
    [self addSubview:headerBezelView];
    _headerBezelView = headerBezelView;
    
    UIScrollView *headerScrollView = [[UIScrollView alloc] init];
    headerScrollView.frame = headerBezelView.bounds;
    headerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    headerScrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [headerBezelView addSubview:headerScrollView];
    _headerScrollView = headerScrollView;
    
    UIView *headerScrollContentView = [[UIView alloc] init];
    headerScrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerScrollView addSubview:headerScrollContentView];
    _headerScrollContentView = headerScrollContentView;
    
    UIView *titleView = [[UIView alloc] init];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerScrollContentView addSubview:titleView];
    _titleView = titleView;
    
    if (self.title.length) {
        self.titleLabel.text = self.title;
        [titleView addSubview:self.titleLabel];
    }
    if (self.message.length) {
        self.detailTitleLabel.text = self.message;
        [titleView addSubview:self.detailTitleLabel];
    }
}
- (void)setupHeaderActionLine {
    UIView *headerActionLine = [[UIView alloc] init];
    headerActionLine.translatesAutoresizingMaskIntoConstraints = NO;
    headerActionLine.backgroundColor = QL_LineColor;
    [self addSubview:headerActionLine];
    _headerActionLine = headerActionLine;
}

- (void)setupViewsAboutAction{
    UIView *actionBezelView = [[UIView alloc] init];
    actionBezelView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:actionBezelView];
    _actionBezelView = actionBezelView;
    
    UIView *actionCenterView = [[UIView alloc] init];
    actionCenterView.translatesAutoresizingMaskIntoConstraints = NO;
    [actionBezelView addSubview:actionCenterView];
    _actionCenterView = actionCenterView;
    
    UITableView *actionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    actionTableView.frame = actionCenterView.bounds;
    actionTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    actionTableView.showsHorizontalScrollIndicator = NO;
    actionTableView.alwaysBounceVertical = NO; // tableView内容没有超出contentSize时，禁止滑动
    actionTableView.backgroundColor = [UIColor clearColor];
    actionTableView.separatorColor = QL_LineColor;
    actionTableView.dataSource = self;
    actionTableView.delegate = self;
    if (@available(iOS 11.0, *)) {
        actionTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [actionTableView registerClass:[QLAlertTableViewCell class] forCellReuseIdentifier:NSStringFromClass([QLAlertTableViewCell class])];
    [actionCenterView addSubview:actionTableView];
    _actionTableView = actionTableView;
}

- (void)setupVFooterTopLine {
    UIView *footerTopLine = [[UIView alloc] init];
    footerTopLine.translatesAutoresizingMaskIntoConstraints = NO;
    footerTopLine.backgroundColor = QL_LineColor;
    [_actionBezelView addSubview:footerTopLine];
    _footerTopLine = footerTopLine;
}

- (void)setupFooterView{
    UIView *footerBezelView = [[UIView alloc] init];
    footerBezelView.translatesAutoresizingMaskIntoConstraints = NO;
    [_actionBezelView addSubview:footerBezelView];
    _footerBezelView = footerBezelView;
}

// 创建底部装载cell的footerView
- (void)createFooterCellWithAction:(QLAlertAction *)action {
    // 这个cell实际上就是一个普通的view，跟tableView没有任何关系，因为cell内部都有现成的控件和布局，直接用这个cell就好，没必要再去自定义一个view，需要注意的是，cell使用了自动布局,contentView会受到影响，看警告对症下药
    QLAlertTableViewCell *footerCell = [[QLAlertTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FOOTERCELL];
    footerCell.translatesAutoresizingMaskIntoConstraints = NO;
    [footerCell.contentView removeFromSuperview]; // 移除后contentView仍然存在，还要将其置为nil，由于是只读的，故用KVC访问
    // 利用KVC去掉cell的contentView,如果不去掉，控制台会打印警告，意思是说contentView的高度不该为0，应该给一个合适的高度
    [footerCell setValue:nil forKey:@"_contentView"];
    footerCell.action = action;
    [self.footerBezelView addSubview:footerCell];
    [self.footerCells addObject:footerCell];
    
    // 之所以添加按钮不用单击手势，是因为按钮做高亮处理更方便
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = footerCell.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(clickedFooterCell:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(touchDownFooterCell:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(touchDragExitFooterCell:) forControlEvents:UIControlEventTouchDragExit | UIControlEventTouchUpOutside];
    [footerCell addSubview:button];
    
    if (self.actions.count > 1) {
        UIView *line = [UIView new];
        line.translatesAutoresizingMaskIntoConstraints = NO;
        line.backgroundColor = QL_LineColor;
        [self.footerBezelView addSubview:line];
        [self.footerLines addObject:line];
    }
}
#pragma mark - 点击取消样式的action的方法
- (void)clickedFooterCell:(UIButton *)sender {
    QLAlertTableViewCell *footerCell = (QLAlertTableViewCell *)sender.superview;
    NSInteger index = [self.footerCells indexOfObject:footerCell];
    QLAlertAction *action = [self.actions objectAtIndex:index];
    // 回调action的block
    if (self.actionHandler) {
        self.actionHandler(action);
        self.actionHandler = nil;
    }
}
- (void)touchDownFooterCell:(UIButton *)sender {
    QLAlertTableViewCell *footerCell = (QLAlertTableViewCell *)sender.superview;
    footerCell.backgroundColor = [UIColor clearColor];
    sender.backgroundColor = QL_SelectedColor;
}

- (void)touchDragExitFooterCell:(UIButton *)sender {
    QLAlertTableViewCell *footerCell = (QLAlertTableViewCell *)sender.superview;
    footerCell.backgroundColor = QL_NormalColor;
    sender.backgroundColor = [UIColor clearColor];
}
#pragma mark - 布局
- (void)layoutViewConstraints {
    // 头部布局
    [self layoutHeader];
    
    // 头部与actionBezelView之间的分割线布局
    [self layoutHeaderActionLine];
    
    // 普通的action子控件布局
    [self layoutCenter];
    
    // footerBezelView顶部的分割线布局,这条分割线将普通样式的action和取消样式的action分隔开来
    [self layoutFooterTopLine];
    
    // footerBezelView布局
    [self layoutFooter];
}
- (void)layoutHeader {
    
    UIView *alertView = self;
    UIView *headerBezelView = self.headerBezelView;
    UIScrollView *headerScrollView = self.headerScrollView;
    UIView *headerScrollContentView = self.headerScrollContentView;
    UIView *titleView = self.titleView;
    UIView *headerActionLine = self.headerActionLine;
    
    NSMutableArray *headerBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *headerScrollContentViewConstraints = [NSMutableArray array];
    NSMutableArray *titleViewConstraints = [NSMutableArray array];
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    
    // 移除存在的约束,删除约束是为了更新约束
    if (self.headerBezelViewConstraints) {
        [alertView removeConstraints:self.headerBezelViewConstraints];
        self.headerBezelViewConstraints = nil;
    }
    if (self.headerScrollContentViewConstraints) {
        [headerScrollView removeConstraints:self.headerScrollContentViewConstraints];
        self.headerScrollContentViewConstraints = nil;
    }
    if (self.titleViewConstraints) {
        [headerScrollContentView removeConstraints:self.titleViewConstraints];
        self.titleViewConstraints = nil;
    }
    if (self.titleLabelConstraints) {
        [titleView removeConstraints:self.titleLabelConstraints];
        self.titleLabelConstraints = nil;
    }
    CGFloat margin = 15;
    
    [headerBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerBezelView)]];
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerActionLine attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    // headerBezelView的高度最大为(self.view.bounds.size.height-itemHeight)
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:QL_ScreenHeight-QL_ActionHeight]];
    // 暂时先初始化headerView的高度约束
    NSLayoutConstraint *headerBezelViewContsraintHeight = [NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0];
    /// 设置优先级
    headerBezelViewContsraintHeight.priority = 998.0;
    [headerBezelViewConstraints addObject:headerBezelViewContsraintHeight];
    [alertView addConstraints:headerBezelViewConstraints];
    
    // 设置actionScrollContentView的相关约束，值得注意的是不能仅仅设置上下左右间距为0就完事了，对于scrollView的contentView， autoLayout布局必须设置宽或高约束
    [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
    [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
    [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerScrollView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
    if (_titleLabel.text.length || _detailTitleLabel.text.length) {
        // 保证headerScrollContentView的高度最小为actionHeight
        [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:QL_ActionHeight]];
    }
    [headerScrollView addConstraints:headerScrollContentViewConstraints];
    
    [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
    [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
    [headerScrollContentView addConstraints:titleViewConstraints];
    
    NSArray *labels = titleView.subviews;
    [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        // 左右间距
        [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==margin)-[label]-(==margin)-|"] options:0 metrics:@{@"margin":@(margin)} views:NSDictionaryOfVariableBindings(label)]];
        // 第一个子控件顶部间距
        if (idx == 0) {
            [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeTop multiplier:1.f constant:margin]];
        }
        // 最后一个子控件底部间距
        if (idx == labels.count - 1) {
            [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-margin]];
        }
        // 子控件之间的垂直间距
        if (idx > 0) {
            NSLayoutConstraint *paddingConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labels[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:margin*0.5];
            [titleLabelConstraints addObject:paddingConstraint];
        }
    }];
    [titleView addConstraints:titleLabelConstraints];
    
    // 先强制布局一次，否则下面拿到的CGRectGetMaxY(titleView.frame)还没有值
    [headerBezelView layoutIfNeeded]; // 立即调用layoutSubViews
    CGRect rect =  titleView.frame;
    // 设置headerView的高度(这个高度同样可以通过计算titleLabel和detailTitleLabel的文字高度计算出来,但是那样计算出来的高度会有零点几的误差,只要差了一点,有可能scrollView即便内容没有超过contentSize,仍然能够滑动)
    headerBezelViewContsraintHeight.constant = CGRectGetMaxY(rect);
    
    // 强制布局，立刻产生frame
    [self layoutIfNeeded];
    
    self.headerBezelViewConstraints = headerBezelViewConstraints;
    self.headerScrollContentViewConstraints  = headerScrollContentViewConstraints;
    self.titleViewConstraints  = titleViewConstraints;
    self.titleLabelConstraints = titleLabelConstraints;
}

- (void)layoutHeaderActionLine {
    
    UIView *alertView = self;
    UIView *headerBezelView = self.headerBezelView;
    UIView *actionBezelView = self.actionBezelView;
    UIView *headerActionLine = self.headerActionLine;
    
    NSMutableArray *headerActionLineConstraints = [NSMutableArray array];
    
    if (self.headerActionLineConstraints) {
        [alertView removeConstraints:self.headerActionLineConstraints];
        self.headerActionLineConstraints = nil;
    }
    CGFloat headerActionPadding = (!headerBezelView.subviews.count || !self.actions.count) ? 0 : QL_LineWidth;
    [headerActionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerActionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerActionLine)]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerBezelView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:headerActionPadding]];
    [alertView addConstraints:headerActionLineConstraints];
    self.headerActionLineConstraints = headerActionLineConstraints;
}

- (void)layoutCenter {
    UIView *alertView = self;
    UIView *headerActionLine = self.headerActionLine;
    UIView *actionBezelView = self.actionBezelView;
    UIView *actionCenterView = self.actionCenterView;
    UIView *footerTopLine = self.footerTopLine;
    
    NSMutableArray *actionBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *actionCenterViewConstraints = [NSMutableArray array];
    
    if (self.actionBezelViewConstraints) {
        [alertView removeConstraints:self.actionBezelViewConstraints];
        self.actionBezelViewConstraints = nil;
    }
    if (self.actionCenterViewConstraints) {
        [actionBezelView removeConstraints:self.actionCenterViewConstraints];
        self.actionCenterViewConstraints = nil;
    }
    // 间距为5，实际上会5.5的高度，因为tableView最后一条分割线跟headerActionLine混合在一起
    CGFloat footerTopMargin = [self footerTopMargin];
    // 计算好actionBezelView的高度, 本也可以让设置每个子控件都高度约束，以及顶底约束和子控件之间的间距，这样便可以把actionBezelView的高度撑起来，但是这里要比较一下actionBezelView和headerView的高度优先级，所以父控件设置高度比较方便，谁的优先级高，谁展示的内容就更多
    CGFloat actionBezelHeight = [self actionBezelHeight:footerTopMargin];
    
    [actionBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelView)]];
    [actionBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerActionLine attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [actionBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    NSLayoutConstraint *actionBezelViewHeightContraint = [NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionBezelHeight];
    // 设置优先级，要比上面headerViewContraintHeight的优先级低,这样当文字过多和action同时过多时，都超出了最大限制，此时优先展示文字
    actionBezelViewHeightContraint.priority = 997.0f;
    // 计算最小高度
    CGFloat minActionHeight = [self minActionHeight:footerTopMargin];
    
    NSLayoutConstraint *minActionHeightConstraint = [NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:minActionHeight];
    [actionBezelViewConstraints addObject:minActionHeightConstraint];
    
    [actionBezelViewConstraints addObject:actionBezelViewHeightContraint];
    [alertView addConstraints:actionBezelViewConstraints];
    
    [actionCenterViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionCenterView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionCenterView)]];
    
    [actionCenterViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionCenterView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerTopLine attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [actionCenterViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionCenterView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [actionBezelView addConstraints:actionCenterViewConstraints];
    
    self.actionBezelViewConstraints = actionBezelViewConstraints;
    self.actionCenterViewConstraints = actionCenterViewConstraints;
}

- (void)layoutFooterTopLine {
    
    UIView *actionBezelView = self.actionBezelView;
    UIView *actionCenterView = self.actionCenterView ;
    UIView *footerBezelView = self.footerBezelView;
    UIView *footerTopLine = self.footerTopLine;
    
    NSMutableArray *footerTopLineConstraints = [NSMutableArray array];
    if (self.footerTopLineConstraints) {
        [actionBezelView removeConstraints:self.footerTopLineConstraints];
        self.footerTopLineConstraints = nil;
    }
    // 没有取消按钮意味着没有非自定义的footerView，如果有自定义的footerView，顶部依然会有0.5的间距，那个间距是tableVeiw最后一条分割线
    CGFloat footerTopMargin = [self footerTopMargin];
    
    [footerTopLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerTopLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerTopLine)]];
    [footerTopLineConstraints addObject:[NSLayoutConstraint constraintWithItem:footerTopLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:actionCenterView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [footerTopLineConstraints addObject:[NSLayoutConstraint constraintWithItem:footerTopLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [footerTopLineConstraints addObject:[NSLayoutConstraint constraintWithItem:footerTopLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:footerTopMargin]];
    [actionBezelView addConstraints:footerTopLineConstraints];
    
    self.footerTopLineConstraints = footerTopLineConstraints;
}

- (void)layoutFooter {
    UIView *actionBezelView = self.actionBezelView;
    UIView *footerTopLine = self.footerTopLine;
    UIView *footerBezelView = self.footerBezelView;
    
    NSMutableArray *footerBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *footerCellConstraints = [NSMutableArray array];
    
    if (self.footerBezelViewConstraints) {
        [actionBezelView removeConstraints:self.footerBezelViewConstraints];
        self.footerBezelViewConstraints = nil;
    }
    if (self.footerCellConstraints) {
        [footerBezelView removeConstraints:self.footerCellConstraints];
        self.footerCellConstraints = nil;
    }
    
    [footerBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerBezelView)]];
    [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerTopLine attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    
    // 这个条件判断需不需要footerBezelView
    if (self.cancelActions.count) { // 需要footerBezelView
        [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:QL_ActionHeight*self.cancelActions.count]];
    } else { // 不需要footerView
        [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0]];
    }
    [actionBezelView addConstraints:footerBezelViewConstraints];
    
    NSArray *footerCells = self.footerCells;
    if (footerCells.count && self.cancelActions.count) {
        [footerCells enumerateObjectsUsingBlock:^(QLAlertTableViewCell *footerCell, NSUInteger idx, BOOL * _Nonnull stop) {
            // 设置footerCell的左右间距
            [footerCellConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerCell]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerCell)]];
            // 第一个footerCell的顶部间距
            if (idx == 0) {
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
            }
            // 最后一个footerCell的底部间距
            if (idx == footerCells.count-1) {
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-0]];
            }
            
            if (idx > 0) {
                // 取出分割线
                UIView *line = self.footerLines[idx-1];
                // 分割线的顶部间距
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerCells[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0]];
                // 分割线的底部间距
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerCells[idx] attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
                // 分割线的左右间距
                [footerCellConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[line]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
                // 分割线的高度
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:QL_LineWidth]];
                // cell的底部间距
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCells[idx-1] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.footerLines[idx - 1] attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
                // cell的顶部间距
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.footerLines[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0]];
                // cell等高
                [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:footerCells[idx - 1] attribute:NSLayoutAttributeHeight multiplier:1.f constant:0]];
            }
        }];
        [footerBezelView addConstraints:footerCellConstraints];
    }
    self.footerBezelViewConstraints = footerBezelViewConstraints;
    self.footerCellConstraints = footerCellConstraints;
}

- (CGFloat)actionBezelHeight:(CGFloat)footerTopMargin {
    CGFloat actionBezelHeight = 0;
    // 计算actionBezelview的高度
    if (self.actions.count) {
        if (self.cancelActions.count) { // 有取消按钮肯定没有自定义footerView
            if (self.actions.count > 1) {
                actionBezelHeight = self.actions.count*QL_ActionHeight+footerTopMargin;
            } else {
                actionBezelHeight = QL_ActionHeight+footerTopMargin;
            }
        } else {
            actionBezelHeight = self.actions.count*QL_ActionHeight;
        }
    }
    return actionBezelHeight;
}

- (CGFloat)minActionHeight:(CGFloat)footerTopMargin {
    CGFloat minActionHeight = 0;
    if (self.cancelActions.count) {
        if ((self.actions.count-self.cancelActions.count) > 3) { // 有取消按钮且其余按钮个数在3个或3个以上
            // 让其余按钮至少显示2个半
            minActionHeight = self.cancelActions.count*QL_ActionHeight+2.5*QL_ActionHeight+footerTopMargin;
        } else {
            minActionHeight = self.actions.count * QL_ActionHeight + footerTopMargin;
        }
    } else {
        if (self.actions.count > 3) { // 没有取消按钮，其余按钮在3个或3个以上
             minActionHeight = 3.5 * QL_ActionHeight;
        } else {
            minActionHeight = self.actions.count * QL_ActionHeight;
        }
    }
    return minActionHeight;
}

- (CGFloat)footerTopMargin {
    CGFloat footerTopMargin = 0;
    if (self.actions.count) {
        if (self.cancelActions.count) {
            footerTopMargin = 5.0f;
        } else {
            footerTopMargin = 0;
        }
    } else {
        footerTopMargin = 0.5;
    }
    return footerTopMargin;
}

#pragma mark TableView DataSource & Delagete
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QLAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QLAlertTableViewCell class]) forIndexPath:indexPath];
    QLAlertAction *action = self.dataSource[indexPath.row];
    cell.action = action;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return QL_ActionHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置cell分割线整宽
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 动画置为NO，如果动画为YES，当点击cell退出控制器时会有延迟,延迟时长时短
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    QLAlertAction *action = self.dataSource[indexPath.row];
    // 回调action的block
    if (self.actionHandler) {
        self.actionHandler(action);
        self.actionHandler = nil;
    }
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
    if (!self.titleLabel.superview) {
        if (_detailTitleLabel) {
            [self.titleView insertSubview:_titleLabel belowSubview:_detailTitleLabel];
        } else {
            [self.titleView addSubview:_titleLabel];
        }
    }
    [self setNeedsUpdateConstraints];
}

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    self.detailTitleLabel.text = message;
    if (!self.detailTitleLabel.superview) {
        [self.titleView addSubview:_detailTitleLabel];
    }
    [self setNeedsUpdateConstraints];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    self.detailTitleLabel.textColor = messageColor;
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    self.detailTitleLabel.font = messageFont;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [_titleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)detailTitleLabel {
    if (!_detailTitleLabel) {
        _detailTitleLabel = [[UILabel alloc] init];
        _detailTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTitleLabel.textAlignment = NSTextAlignmentCenter;
        _detailTitleLabel.numberOfLines = 0;
        _detailTitleLabel.font = [UIFont systemFontOfSize:14];
        _detailTitleLabel.alpha = 0.5;
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [_detailTitleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [_detailTitleLabel sizeToFit];
    }
    return _detailTitleLabel;
}

- (NSMutableArray *)footerCells {
    
    if (!_footerCells) {
        _footerCells = [NSMutableArray array];
    }
    return _footerCells;
}

- (NSMutableArray *)footerLines {
    
    if (!_footerLines) {
        _footerLines = [NSMutableArray array];
    }
    return _footerLines;
}

- (NSArray<QLAlertAction *> *)actions {
    if (!_actions) {
        _actions = [NSArray array];
    }
    return _actions;
}

- (NSMutableArray *)cancelActions {
    if (!_cancelActions) {
        _cancelActions = [NSMutableArray array];
    }
    return _cancelActions;
}


@end
