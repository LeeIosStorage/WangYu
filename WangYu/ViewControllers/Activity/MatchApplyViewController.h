//
//  MatchApplyViewController.h
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYMatchInfo.h"
#import "WYTeamInfo.h"

typedef enum ApplyViewType_ {
    ApplyViewTypeNormal = 0,      // 普通的
    ApplyViewTypeTeam,            // 队伍
    ApplyViewTypeSol,             // 个人
    ApplyViewTypeJoin,            // 加入战队
}ApplyViewType;

@interface MatchApplyViewController : WYSuperViewController

@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, strong) WYMatchInfo *matchInfo;
@property (nonatomic, strong) WYTeamInfo *teamInfo;
@property (nonatomic, assign) ApplyViewType applyType;

@end
