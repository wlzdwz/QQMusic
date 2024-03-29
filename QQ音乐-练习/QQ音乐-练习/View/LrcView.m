//
//  LrcView.m
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "LrcView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LrcLine.h"
#import "LrcTool.h"
#import "LrcViewCell.h"
#import "LrcLabel.h"
#import "Music.h"
#import "MusicTool.h"

@interface LrcView ()<UITableViewDataSource>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** 歌词的数据 */
@property (nonatomic, strong) NSArray *lrclist;

/** 当前播放的歌词的下标 */
@property (nonatomic, assign) NSInteger currentIndex;


@end

@implementation LrcView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupTableView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
//        [self setupTableView];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupTableView];
}

- (void)setupTableView
{
    // 1.创建tableView
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 35;
    [self addSubview:tableView];
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView = tableView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.right.equalTo(self.mas_right);
        make.width.equalTo(self.mas_width);
    }];
    
    // 设置tableView多出的滚动区域
    self.tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
}


#pragma mark- 重写setLrcName方法
- (void)setLrcName:(NSString *)lrcName{
    // 0.重置保存的当前位置的下标
    self.currentIndex = 0;
    
    // 1.保存歌词名称
    _lrcName = [lrcName copy];
    
    // 2.解析歌词
    self.lrclist = [LrcTool lrcToolWithLrcName:lrcName];
    
    // 3.刷新表格
    [self.tableView reloadData];
}

#pragma mark- 重写setCurrentTime
- (void)setCurrentTime:(NSTimeInterval)currentTime{
    _currentTime = currentTime;
    
    //用当前时间和歌词进行匹配
    NSInteger count = self.lrclist.count;
    for (NSInteger i = 0; i < count; i++) {
        //1.拿到该位置的歌词
        LrcLine *currentLrcLine = self.lrclist[i];
        
        //2.拿到下一句歌词
        NSInteger nextIndex = i + 1;
        LrcLine *nextLrcLine = nil;
        if (nextIndex < count) {
            nextLrcLine = self.lrclist[nextIndex];
        }
        
        //3.用当前的时间和i位置的歌词比较,并且和下一句比较,如果大于i位置的时间并且小于下一句歌词的时间,那么显示当前的歌词
        if (self.currentIndex != i && currentTime >= currentLrcLine.time && currentTime < nextLrcLine.time) {
            
            //1.获取需要刷新的行号
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            //2.记录当前行号
            self.currentIndex = i;
            
            //3.刷新当前行和上一行
            [UIView performWithoutAnimation:^{
                [self.tableView reloadRowsAtIndexPaths:@[indexPath, previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                //4.显示对应句的歌词
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];
            
            
            //5.设置外面歌词的label的显示歌词
            self.lrcLabel.text = currentLrcLine.text;
            
            //6.生成锁屏界面
            [self generateLockImage];
        }
        
        if (self.currentIndex == i) {
            //计算歌词进度progress
            CGFloat progress = (currentTime - currentLrcLine.time) / (nextLrcLine.time - currentLrcLine.time);
            //拿到当前的cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LrcViewCell *cell = (LrcViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.lrcLabel.progress = progress;
            
            //外部单行歌词的显示
            self.lrcLabel.progress = progress;
            
        }
        
    }
    
}

#pragma mark- 生成锁屏界面
- (void)generateLockImage{
    // 1.拿到当前歌曲的图片
    Music *playingMusic = [MusicTool playingMusic];
    UIImage *currentImage = [UIImage imageNamed:playingMusic.icon];
    
    // 2.拿到三句歌词
    // 2.1.获取当前的歌词
    LrcLine *currentLrc = self.lrclist[self.currentIndex];
    // 2.2.上一句歌词
    NSInteger previousIndex = self.currentIndex - 1;
    LrcLine *prevousLrc = nil;
    if (previousIndex >= 0) {
        prevousLrc = self.lrclist[previousIndex];
    }
    // 2.3.下一句歌词
    NSInteger nextIndex = self.currentIndex + 1;
    LrcLine *nextLrc = nil;
    if (nextIndex < self.lrclist.count) {
        nextLrc = self.lrclist[nextIndex];
    }
    
    // 3.生成水印图片
    // 3.1.获取上下文
    UIGraphicsBeginImageContext(currentImage.size);
    // 3.2.将图片画上去
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    // 3.3.将歌词画到图片上
    CGFloat titleH = 25;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0],
                                  NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                  NSParagraphStyleAttributeName : style};
    [prevousLrc.text drawInRect:CGRectMake(0, currentImage.size.height - titleH * 3, currentImage.size.width, titleH) withAttributes:attributes1];
    [nextLrc.text drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH)  withAttributes:attributes1];
    
    NSDictionary *attributes2 = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0],
                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSParagraphStyleAttributeName : style};
    [currentLrc.text drawInRect:CGRectMake(0, currentImage.size.height - titleH * 2, currentImage.size.width, titleH)  withAttributes:attributes2];
    
    // 4.生成图片
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.设置锁屏信息
    [self setupLockScreenInfoWithLockImage:lockImage];
    
    // 6.关闭
    UIGraphicsEndImageContext();
    
}


// MPMediaItemPropertyAlbumTitle
// MPMediaItemPropertyAlbumTrackCount
// MPMediaItemPropertyAlbumTrackNumber
// MPMediaItemPropertyArtist
// MPMediaItemPropertyArtwork
// MPMediaItemPropertyComposer
// MPMediaItemPropertyDiscCount
// MPMediaItemPropertyDiscNumber
// MPMediaItemPropertyGenre
// MPMediaItemPropertyPersistentID
// MPMediaItemPropertyPlaybackDuration
// MPMediaItemPropertyTitle
- (void)setupLockScreenInfoWithLockImage:(UIImage *)lockImage{
    //0.获取当前正在播放的歌曲
    Music *playingMusic = [MusicTool playingMusic];
    
    //1.获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];

    //2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    //标题
    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyTitle];
    //作者
    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    //背景图片
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    [playingInfo setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [playingInfo setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    playingInfoCenter.nowPlayingInfo = playingInfo;
    //3.让应用程序可以接收远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
}

#pragma mark - 实现tableView数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrclist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建Cell
    LrcViewCell *cell = [LrcViewCell lrcCellWithTableView:tableView];
    
    if (self.currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:14.0];
        cell.lrcLabel.progress = 0;
    }
    
    // 2.给cell设置数据
    // 2.1.取出模型
    LrcLine *lrcline = self.lrclist[indexPath.row];
    
    // 2.2.给cell设置数据
    cell.lrcLabel.text = lrcline.text;
    
    return cell;
}


@end
