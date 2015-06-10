//
//  WYPhotoGroup.m
//  WangYu
//
//  Created by 许 磊 on 15/5/21.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYPhotoGroup.h"
#import "WYPhotoItem.h"
#import "UIButton+WebCache.h"
#import "WYPhotoBrowser.h"

#define WYPhotoGroupImageMargin 15
#define WY_PHOTO_GROUP_TAG 10000

@interface WYPhotoGroup () <WYPhotoBrowserDelegate>

@end

@implementation WYPhotoGroup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除图片缓存，便于测试
//        [[SDWebImageManager sharedManager].imageCache clearDisk];
    }
    return self;
}

- (void)setPhotoItemArray:(NSArray *)photoItemArray
{
    _photoItemArray = photoItemArray;
    [photoItemArray enumerateObjectsUsingBlock:^(WYPhotoItem *obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [[UIButton alloc] init];
//        [btn sd_setImageWithURL:[NSURL URLWithString:obj.thumbnail_pic] forState:UIControlStateNormal];
        [btn sd_setImageWithURL:[NSURL URLWithString:obj.thumbnail_pic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
        btn.tag = idx + WY_PHOTO_GROUP_TAG;
        
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    long imageCount = self.photoItemArray.count;
//    int perRowImageCount = ((imageCount == 4) ? 2 : 3);
//    CGFloat perRowImageCountF = (CGFloat)perRowImageCount;
//    int totalRowCount = ceil(imageCount / perRowImageCountF); // ((imageCount + perRowImageCount - 1) / perRowImageCount)
//    CGFloat w = 80;
//    CGFloat h = 69;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        
//        long rowIndex = idx / perRowImageCount;
//        int columnIndex = idx % perRowImageCount;
//        CGFloat x = columnIndex * (w + WYPhotoGroupImageMargin);
//        CGFloat y = rowIndex * (h + WYPhotoGroupImageMargin);
//        btn.frame = CGRectMake(x, y, w, h);
        btn.frame = CGRectMake(12 + idx*(80+7), 12, 80, 69);
    }];
    
    self.frame = CGRectMake(0, 0, imageCount * 87 + 12, 93);
}

- (void)buttonClick:(UIButton *)button
{
    WYPhotoBrowser *browser = [[WYPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self;       // 原图的父控件
    browser.imageCount = self.photoItemArray.count; // 图片总数
    browser.currentImageIndex = (int)button.tag - WY_PHOTO_GROUP_TAG;
    browser.delegate = self;
    [browser show];
    
}

#pragma mark - photobrowserDelegate

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(WYPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    //return [self.subviews[index] currentImage];
    if ([self.subviews[index] currentImage] != nil) {
        return [self.subviews[index] currentImage];
    }
    return [UIImage imageNamed:@"netbar_load_icon"];
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(WYPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlStr = [[self.photoItemArray[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
}

- (void)statusBarNeedsHidden:(BOOL)bHidden {
    if ([self.delegate respondsToSelector:@selector(controllerStatusBarHidden:)]) {
        return [self.delegate controllerStatusBarHidden:bHidden];
    }
}

@end
