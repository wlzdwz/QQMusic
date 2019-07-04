//
//  LrcTool.m
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/26.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "LrcTool.h"
#import "LrcLine.h"

@implementation LrcTool

+ (NSArray *)lrcToolWithLrcName:(NSString *)lrcName{
    //1.拿到歌词文件的路径
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:lrcName ofType:nil];
    
    //2.读取歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    
    //3.拿到歌词的数组
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    
    //4.遍历每一句歌词,转成模型
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *lrclineString in lrcArray) {
        //拿到每一句歌词
        /*
         [ti:心碎了无痕]
         [ar:张学友]
         [al:]
         */
        BOOL vilidateLrc = [lrclineString hasPrefix:@"[ti:"] || [lrclineString hasPrefix:@"[ar:"] || [lrclineString hasPrefix:@"[al:"] || ![lrclineString hasPrefix:@"["];
        if (vilidateLrc) {
            continue;
        }
        
        //将歌词转换成模型
        LrcLine *line = [LrcLine lrcLineWithLrclineString:lrclineString];
        [tempArray addObject:line];
    }
    
    
    return tempArray;
}

@end
