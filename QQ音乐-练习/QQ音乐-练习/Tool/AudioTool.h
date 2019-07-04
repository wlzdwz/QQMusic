//
//  AudioTool.h
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioTool : NSObject

+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName;
+ (void)pauseMusicWithMusicName:(NSString *)musicName;
+ (void)stopMusicWithMusicName:(NSString *)musicName;


@end

