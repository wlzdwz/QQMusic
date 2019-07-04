//
//  LrcLine.h
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/26.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LrcLine : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithLrclineString:(NSString *)lrclineString;
+ (instancetype)lrcLineWithLrclineString:(NSString *)lrclineString;

@end

NS_ASSUME_NONNULL_END
