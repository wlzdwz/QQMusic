//
//  LrcViewCell.h
//  QQ音乐-练习
//
//  Created by wuliangzhi on 2019/6/25.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LrcLabel;
@interface LrcViewCell : UITableViewCell

/** label */
@property(nonatomic,strong,readonly)LrcLabel *lrcLabel;


+ (instancetype)lrcCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
