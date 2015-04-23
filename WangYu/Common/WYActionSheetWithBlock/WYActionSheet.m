//
//  WYActionSheet.m
//  WangYu
//
//  Created by KID on 15/1/9.
//
//

#import "WYActionSheet.h"

@interface WYActionSheet()<UIActionSheetDelegate>

@property (nonatomic, strong) WYActionSheetBlcok clickBlock;
@end

@implementation WYActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//init action with block
-(id)initWithTitle:(NSString *)title actionBlock:(WYActionSheetBlcok) actionBlock cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    if(self){
        _clickBlock = actionBlock;
        va_list strButtonNameList;
        va_start(strButtonNameList, otherButtonTitles);
        for (NSString *strBtnTitle = otherButtonTitles; strBtnTitle != nil; strBtnTitle = va_arg(strButtonNameList, NSString*))
        {
            [self addButtonWithTitle:strBtnTitle];
        }
        va_end(strButtonNameList);
        
        if (destructiveButtonTitle.length > 0) {
            [self addButtonWithTitle:destructiveButtonTitle];
            self.destructiveButtonIndex = self.numberOfButtons - 1;
        }
        
        //默认都是有取消
        if (cancelButtonTitle.length > 0) {
            [self addButtonWithTitle:cancelButtonTitle];
            self.cancelButtonIndex = self.numberOfButtons - 1;
        }
    }
    
    return self;
}

-(id) initWithTitle:(NSString *)title actionBlock:(WYActionSheetBlcok)actionBlock
{
    return [self initWithTitle:title actionBlock:actionBlock cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
}

#pragma mark - Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.clickBlock)
        self.clickBlock(buttonIndex);
}

@end
