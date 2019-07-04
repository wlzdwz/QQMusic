//
//  LrcView.h
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LrcLabel;
@interface LrcView : UIScrollView

@property (nonatomic, copy) NSString *lrcName;
/** 歌词label */
@property(nonatomic,strong)LrcLabel *lrcLabel;


/** 当前播放的时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;

/** 当前歌曲的总时长 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
