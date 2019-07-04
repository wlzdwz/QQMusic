//
//  LrcLabel.m
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/26.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "LrcLabel.h"

@implementation LrcLabel

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //1.获取需要画的区域:这里不用rect是为了使数据更加准确,因为约束有时候是不准的
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
    
    //2.设置颜色
    [[UIColor redColor] set];
    
    //3.添加区域
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
    
}


@end
