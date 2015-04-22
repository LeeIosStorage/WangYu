//
//  XEActionSheet.h
//  WangYu
//
//  Created by KID on 15/1/9.
//
//

#import <UIKit/UIKit.h>

typedef void (^XEActionSheetBlcok) (NSInteger buttonIndex);

@interface XEActionSheet : UIActionSheet

//init action with block
-(id)initWithTitle:(NSString *)title actionBlock:(XEActionSheetBlcok) actionBlock cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

-(id) initWithTitle:(NSString *)title actionBlock:(XEActionSheetBlcok)actionBlock;

@end
