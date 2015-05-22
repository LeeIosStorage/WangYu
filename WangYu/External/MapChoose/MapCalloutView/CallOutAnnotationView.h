

//
//  CallOutAnnotationView.h
//
//  Created by Jian-Ye on 12-11-8.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//
#import <MapKit/MapKit.h>

#define  Arror_height 15

@protocol CallOutAnnotationViewDelegate;
@interface CallOutAnnotationView : MKAnnotationView

@property (nonatomic,strong)UIView *contentView;


- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
                delegate:(id<CallOutAnnotationViewDelegate>)delegate;
@end

@protocol CallOutAnnotationViewDelegate <NSObject>

- (void)didSelectAnnotationView:(CallOutAnnotationView *)view;

@end


