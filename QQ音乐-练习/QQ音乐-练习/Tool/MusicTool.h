//
//  MusicTool.h
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Music.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicTool : NSObject

+ (NSArray *)musics;

+ (Music *)playingMusic;

+ (void)setPlayingMusic:(Music *)playingMusic;

+ (Music *)nextMusic;

+ (Music *)previousMusic;


@end

NS_ASSUME_NONNULL_END
