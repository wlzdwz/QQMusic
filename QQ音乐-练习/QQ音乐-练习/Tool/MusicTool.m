//
//  MusicTool.m
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "MusicTool.h"

@implementation MusicTool

static NSArray *_musics;
static Music *_playingMusic;

+ (void)initialize
{
    if (_musics == nil) {
        _musics = [Music mj_objectArrayWithFilename:@"Musics.plist"];
    }
    
    if (_playingMusic == nil) {
        _playingMusic = _musics[1];
    }
}

+ (NSArray *)musics
{
    return _musics;
}

+ (Music *)playingMusic
{
    return _playingMusic;
}

+ (void)setPlayingMusic:(Music *)playingMusic
{
    _playingMusic = playingMusic;
}

+ (Music *)nextMusic
{
    // 1.拿到当前播放歌词下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.取出下一首
    NSInteger nextIndex = ++currentIndex;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    Music *nextMusic = _musics[nextIndex];
    
    return nextMusic;
}

+ (Music *)previousMusic
{
    // 1.拿到当前播放歌词下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.取出下一首
    NSInteger previousIndex = --currentIndex;
    if (previousIndex < 0) {
        previousIndex = _musics.count - 1;
    }
    Music *previousMusic = _musics[previousIndex];
    
    return previousMusic;
}


@end
