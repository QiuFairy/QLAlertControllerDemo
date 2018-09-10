//
//  ViewController.m
//  QLAlertControllerDemo
//
//  Created by qiu on 2018/9/5.
//  Copyright © 2018年 QiuFairy. All rights reserved.
//

#import "ViewController.h"
#import "QLAlertController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    UIButton *alert = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, 200, 44)];
    alert.backgroundColor = [UIColor redColor];
    [alert addTarget:self action:@selector(clickAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alert];
    
    UIButton *sheet = [[UIButton alloc]initWithFrame:CGRectMake(10, 200, 200, 44)];
    sheet.backgroundColor = [UIColor redColor];
    [sheet addTarget:self action:@selector(clickSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sheet];
}

-(void)clickAlert{
    [self actionAlertTest1];
}
-(void)clickSheet{
    [self actionSheetTest1];
}

// 示例1:actionSheet的默认动画样式(从底部弹出)
- (void)actionAlertTest1 {
    // actionSheet中，QLAlertAnimationTypeDefault 等价于 QLAlertAnimationTypeRaiseUp
    QLAlertController *alertController = [QLAlertController alertControllerWithTitle:@"这是大标题D大多撒好见风使舵开发并防守打法还记得上发布递归第三方黑人过水电费播放的伙食费返回啥刚入手的内裤是你姐夫昆仑决赔钱货日发放的很干净的地方就看过你剪短发放得开是根据" message:@"这是小标题大声道撒大所多人工台基本面闺女家风格挖到个专升本的金额非非金融是没地方不能退" preferredStyle:QLAlertControllerStyleAlert];
    alertController.titleColor = [UIColor redColor];
    alertController.titleFont = [UIFont systemFontOfSize:20];
    alertController.maxNumberOfActionHorizontalArrangementForAlert = 3;
    
    QLAlertAction *action1 = [QLAlertAction actionWithTitle:@"Default" style:QLAlertActionStyleDefault handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Default ");
    }];
    action1.titleColor = [UIColor greenColor];
    
    QLAlertAction *action2 = [QLAlertAction actionWithTitle:@"Destructive" style:QLAlertActionStyleDestructive handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Destructive");
    }];
    QLAlertAction *action3 = [QLAlertAction actionWithTitle:@"Cancel" style:QLAlertActionStyleCancel handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
    }];
    [alertController addAction:action1];
    [alertController addAction:action3]; // 注意第3个按钮是第2个添加，但是最终会显示在最底部，因为第四个按钮是取消按钮，只要是取消按钮，一定会在最底端，其余按钮按照添加顺序依次排布
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例1:actionSheet的默认动画样式(从底部弹出)
- (void)actionSheetTest1 {
    // actionSheet中，QLAlertAnimationTypeDefault 等价于 QLAlertAnimationTypeRaiseUp
    QLAlertController *alertController = [QLAlertController alertControllerWithTitle:@"这是大标题D大多撒好见风使舵开发并防守打法还记得上发布递归第三方黑人过水电费播放的伙食费返回啥刚入手的内裤是你姐夫昆仑决赔钱货日发放的很干净的地方就看过你剪短发放得开是根据" message:@"这是小标题" preferredStyle:QLAlertControllerStyleActionSheet];
    QLAlertAction *action1 = [QLAlertAction actionWithTitle:@"Default" style:QLAlertActionStyleDefault handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Default ");
    }];
    QLAlertAction *action2 = [QLAlertAction actionWithTitle:@"Destructive" style:QLAlertActionStyleDestructive handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Destructive");
    }];
    QLAlertAction *action3 = [QLAlertAction actionWithTitle:@"Cancel" style:QLAlertActionStyleCancel handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
    }];
    QLAlertAction *action4 = [QLAlertAction actionWithTitle:@"Cancel2" style:QLAlertActionStyleCancel handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
    }];
    QLAlertAction *action5 = [QLAlertAction actionWithTitle:@"Cancel3" style:QLAlertActionStyleCancel handler:^(QLAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
    }];
    [alertController addAction:action4];
    [alertController addAction:action5];
    
    [alertController addAction:action1];
    [alertController addAction:action3]; // 注意第3个按钮是第2个添加，但是最终会显示在最底部，因为第四个按钮是取消按钮，只要是取消按钮，一定会在最底端，其余按钮按照添加顺序依次排布
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
