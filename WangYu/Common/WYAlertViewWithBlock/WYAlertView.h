//
//  RVAlertViewWithBlocks.h
//  RVAlertViewWithBlock
//
//  Created by Rubén Vázquez on 9/15/13.
//  
//  Copyright (c) 2013 WhiteYelloW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYAlertView : UIAlertView


- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle cancelBlock:(void(^)(void))cancelBlock;
/*
    Currently just accepting two buttons and two blocks. 
 */
- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle cancelBlock:(void(^)(void))cancelBlock okButtonTitle:(NSString*)okButtonTitle okBlock:(void(^)(void))okBlock;

//纯提示
-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitile;
@end
