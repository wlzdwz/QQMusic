//
//  ViewController.m
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/24.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CALayer+PauseAimate.h"
#import "NSString+Time.h"
#import "MusicTool.h"
#import "AudioTool.h"
#import "LrcView.h"
#import "LrcLabel.h"

@interface ViewController ()<UIScrollViewDelegate, AVAudioPlayerDelegate>
//背景
@property (weak, nonatomic) IBOutlet UIImageView *albumView;
//滑动尺
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
//播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
//歌词view
@property (weak, nonatomic) IBOutlet LrcView *lrcView;
//歌词label
@property (weak, nonatomic) IBOutlet LrcLabel *lrcLabel;

/** 歌词更新的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;

/** 定时器 */
@property(nonatomic,strong)NSTimer *progressTimer;

/** 当前的播放器 */
@property (nonatomic, strong) AVAudioPlayer *currentPlayer;

#pragma mark- 手势点击
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;

- (IBAction)playAction:(UIButton *)sender;
- (IBAction)previous:(UIButton *)sender;
- (IBAction)next:(UIButton *)sender;

@end

#define RGB(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]

@implementation ViewController

- (NSTimer *)progressTimer{
    if (!_progressTimer) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    }
    return _progressTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.创建模糊视图
    [self setupBlurView];
    
    //2.设置滑块的图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    //3.开始播放音乐
    [self startPlayingMusic];
    
    //4.设置lrcView的ContentSize
    self.lrcView.contentSize = CGSizeMake(self.view.frame.size.width * 2, 0);
    
    //5.赋值歌词label
    self.lrcView.lrcLabel = self.lrcLabel;
        
}

//设置图片圆角
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.width * 0.5;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderWidth = 8.0;
    self.iconView.layer.borderColor = RGB(36, 36, 36).CGColor;
}

- (void)setupBlurView{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setBarStyle:UIBarStyleBlack];
    [self.albumView addSubview:toolBar];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.albumView);
    }];
}

#pragma mark- 开始播放音乐
- (void)startPlayingMusic{
    //1.取出当前播放歌曲
    Music *playingMusic = [MusicTool playingMusic];
    
    //2.设置界面信息
    self.albumView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.singerLabel.text = playingMusic.singer;
    
    //3.开始播放音乐
    AVAudioPlayer *currentPlayer = [AudioTool playMusicWithMusicName:playingMusic.filename];
    self.currentPlayer = currentPlayer;
    currentPlayer.delegate = self;
    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    self.totalTimeLabel.text = [NSString stringWithTime:currentPlayer.duration];
    self.playButton.selected = self.currentPlayer.isPlaying;
    
    //4.设置歌词
    self.lrcView.lrcName = playingMusic.lrcname;
    
    self.lrcLabel.text = @"";
    
    self.lrcView.duration = currentPlayer.duration;
    
    //4.开始播放动画
    [self startIconViewAnimation];
    
    //5.添加定时器用户更新进度界面
    [self removeProgressTimer];
    [self addProgressTimer];
    [self removeLrcTimer];
    [self addLrcTimer];
    
    //测试
//    [self setupLockScreenInfo];
    
}

- (void)setupLockScreenInfo
{
    // 0.获取当前正在播放的歌曲
    Music *playingMusic = [MusicTool playingMusic];
    
    // 1.获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:playingMusic.icon]];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    [playingInfo setObject:@(self.currentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    // 3.让应用程序可以接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}


//图像旋转
- (void)startIconViewAnimation{
    // 1.创建基本动画
    CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 2.设置基本动画属性
    rotateAnim.fromValue = @(0);
    rotateAnim.toValue = @(M_PI * 2);
    rotateAnim.repeatCount = NSIntegerMax;
    rotateAnim.duration = 40;
    
    // 3.添加动画到图层上
    [self.iconView.layer addAnimation:rotateAnim forKey:nil];
}

#pragma mark - 对定时器的操作
- (void)addProgressTimer
{
    [self updateProgressInfo];
    [self.progressTimer setFireDate:[NSDate date]];
}

- (void)removeProgressTimer
{
//    [self.progressTimer invalidate];
//    self.progressTimer = nil;
    [self.progressTimer setFireDate:[NSDate distantFuture]];
}

- (void)addLrcTimer{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

#pragma mark - 更新歌词
- (void)updateLrc
{
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}


#pragma mark - 更新进度的界面
- (void)updateProgressInfo
{
    // 1.设置当前的播放时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 2.更新滑块的位置
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}

#pragma mark- 滑动尺事件

- (IBAction)startSlide:(UISlider *)sender {
    //移除定时器
    [self removeProgressTimer];
}

- (IBAction)valueChange:(UISlider *)sender {
    // 设置当前播放的时间Label
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.duration * self.progressSlider.value];
}

- (IBAction)endChange:(UISlider *)sender {
    // 1.设置歌曲的播放时间
    self.currentPlayer.currentTime = self.progressSlider.value * self.currentPlayer.duration;
    
    // 2.添加定时器
    [self addProgressTimer];
    
}


- (IBAction)sliderClick:(UITapGestureRecognizer *)sender {    
    //获取点击的位置
    CGPoint point = [sender locationInView:sender.view];
    
    //位置的比例
    CGFloat ratio = point.x / self.progressSlider.frame.size.width;
    
    //改变歌曲的播放时长
    self.currentPlayer.currentTime = ratio * self.currentPlayer.duration;
    
    //更新进度信息
    [self updateProgressInfo];
}

- (IBAction)playAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.currentPlayer.playing) {
        [self.currentPlayer pause];
        [self removeProgressTimer];
        [self removeLrcTimer];
        //暂停iconView的动画
        [self.iconView.layer pauseAnimate];
    }else{
        [self.currentPlayer play];
        [self addProgressTimer];
        [self addLrcTimer];
        //恢复iconView的动画
        [self.iconView.layer resumeAnimate];
    }
    
}

- (IBAction)previous:(UIButton *)sender {
    Music *previouseMusic = [MusicTool previousMusic];
    [self playMusicWithMusic:previouseMusic];
}

- (IBAction)next:(UIButton *)sender {
    Music *music = [MusicTool nextMusic];
    [self playMusicWithMusic:music];
}

- (void)playMusicWithMusic:(Music *)music{
    //1.停止当前歌曲
    Music *playingMusic = [MusicTool playingMusic];
    [AudioTool stopMusicWithMusicName:playingMusic.filename];
    
    //3.播放i新歌曲
    [AudioTool playMusicWithMusicName:music.filename];
    
    //4.将工具类中的当前歌曲切换
    [MusicTool setPlayingMusic:music];
    
    //5.切换界面信息
    [self startPlayingMusic];
}

#pragma mark - 实现UIScrollView的代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 1.获取到滑动多少
    CGPoint point = scrollView.contentOffset;
    
    // 2.计算滑动的比例
    CGFloat ratio = 1 - point.x / scrollView.bounds.size.width;
    
    // 3.设置iconView和歌词的Label的透明度
    self.iconView.alpha = ratio;
    self.lrcLabel.alpha = ratio;
}

#pragma mark- AVAudioplayer的代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self next:nil];
    }
}

//监听远程事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:{
            self.playButton.selected = YES;
            [self playAction:nil];
        }break;
        case UIEventSubtypeRemoteControlPause:
        {
            self.playButton.selected = NO;
            [self playAction:nil];
        }
            break;
            case UIEventSubtypeRemoteControlNextTrack:
            [self next:nil];
            break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous:nil];
        default:
            break;
    }
}


- (void)dealloc{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

@end
