//
//  WYPhotoBrowser.h
//  WangYu
//
//  Created by 许 磊 on 15/5/21.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYPhotoBrowser;

@protocol WYPhotoBrowserDelegate <NSObject>

@required
- (UIImage *)photoBrowser:(WYPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;
@optional
- (NSURL *)photoBrowser:(WYPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

- (void)statusBarNeedsHidden:(BOOL)bHidden;

@end

@interface WYPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) int currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, weak) id<WYPhotoBrowserDelegate> delegate;

- (void)show;

@end
