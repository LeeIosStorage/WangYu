//
//  XEScrollPage.h
//  Xiaoer
//
//  Created by KID on 15/1/15.
//
//

#import <UIKit/UIKit.h>

//广告位种类
typedef enum AdsType_{
    AdsType_Theme,
    AdsType_News,
}AdsType;

@protocol WYScrollPageDelegate<NSObject>

@optional
- (void)didTouchPageView:(NSInteger)index;
- (void)didTouchHideButton;

@end

@interface WYScrollPage : UIView

//滚动数据源
@property (nonatomic, strong) NSMutableArray *dataArray;
//滚动时长
@property (nonatomic, assign) int duration;
//广告种类
@property (nonatomic, assign) AdsType adsType;
@property (nonatomic, assign) id <WYScrollPageDelegate> delegate;

@end
