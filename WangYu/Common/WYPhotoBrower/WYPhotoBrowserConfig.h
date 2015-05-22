//
//  WYPhotoBrowserConfig.h
//  WangYu
//
//  Created by 许 磊 on 15/5/21.
//  Copyright (c) 2015年 KID. All rights reserved.
//

typedef enum {
    WYWaitingViewModeLoopDiagram, // 环形
    WYWaitingViewModePieDiagram // 饼型
} WYWaitingViewMode;

// 图片保存成功提示文字
#define WYPhotoBrowserSaveImageSuccessText @" ^_^ 保存成功 ";

// 图片保存失败提示文字
#define WYPhotoBrowserSaveImageFailText @" >_< 保存失败 ";

// browser背景颜色
#define WYPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// browser中图片间的margin
#define WYPhotoBrowserImageViewMargin 10

// browser中显示图片动画时长
#define WYPhotoBrowserShowImageAnimationDuration 0.6f

// browser中显示图片动画时长
#define WYPhotoBrowserHideImageAnimationDuration 0.6f

// 图片下载进度指示进度显示样式（SDWaitingViewModeLoopDiagram 环形，SDWaitingViewModePieDiagram 饼型）
#define WYWaitingViewProgressMode WYWaitingViewModeLoopDiagram

// 图片下载进度指示器背景色
#define WYWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

// 图片下载进度指示器内部控件间的间距
#define WYWaitingViewItemMargin 10
