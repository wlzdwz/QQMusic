//
//  AudioTool.m
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "AudioTool.h"


static NSMutableDictionary *_players;

@implementation AudioTool

+ (void)initialize{
    _players = [NSMutableDictionary dictionary];
}


+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName{
    //名字不能为空
    assert(musicName);
    
    //1.定义播放器
    AVAudioPlayer *player = nil;
    player = _players[musicName];
    if (player == nil) {
        //2.1获取对应的音乐资源
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
        
        if(fileUrl == nil)return nil;
        
        //2.2创建对应的播放器
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        
        //2.3将players存入字典中
        [_players setObject:player forKey:musicName];
        
        //2.4准备播放
        [player prepareToPlay];
        
    }
    
    //3.播放音乐
    [player play];
    
    return player;
}

+ (void)pauseMusicWithMusicName:(NSString *)musicName{
    assert(musicName);
    
    //1.取出对应的播放器,
    AVAudioPlayer *player = _players[musicName];
    
    //2.判断player是否是nil
    if (player) {
        [player pause];
    }
    
}

+ (void)stopMusicWithMusicName:(NSString *)musicName{
    assert(musicName);
    
    //1.取出对应的播放器,
    AVAudioPlayer *player = _players[musicName];
    
    //2.判断player是否是nil
    if (player) {
        [player stop];
        [_players removeObjectForKey:musicName];
        player = nil;
    }
}


@end
