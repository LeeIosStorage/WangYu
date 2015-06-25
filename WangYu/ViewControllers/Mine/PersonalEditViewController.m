//
//  PersonalEditViewController.m
//  WangYu
//
//  Created by KID on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PersonalEditViewController.h"
#import "WYEngine.h"
#import "QHQnetworkingTool.h"
#import "WYProgressHUD.h"
#import "WYActionSheet.h"
#import "AVCamUtilities.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "WYUserInfo.h"
#import "UIImageView+WebCache.h"
#import "WYAlertView.h"
#import "AvatarListViewController.h"

@interface PersonalEditViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AvatarListViewControllerDelegate>
{
    UIImage *_avatarImage;
    NSData *_avatarData;
    NSString *_recommendUserHeadPic;
    
    WYUserInfo *_oldUserInfo;
}
@property (strong, nonatomic) IBOutlet UIView *personalContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIButton *affirmButton;
@property (strong, nonatomic) IBOutlet UITextField *nickNameTextField;
@property(nonatomic, assign) int maxTextLength;

@property (nonatomic, assign) BOOL bViewDisappear;

- (IBAction)albumAction:(id)sender;
- (IBAction)affirmAction:(id)sender;

@end

@implementation PersonalEditViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [_nickNameTextField resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _bViewDisappear = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _bViewDisappear = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    WYUserInfo* tmpUserInfo = [WYEngine shareInstance].userInfo;
    if (tmpUserInfo == nil || tmpUserInfo.uid.length == 0) {
        [WYProgressHUD AlertError:@"用户不存在"];
    }
    _oldUserInfo = [[WYUserInfo alloc] init];
    [_oldUserInfo setUserInfoByJsonDic:tmpUserInfo.userInfoByJsonDic];
    
    
    _nickNameTextField.text = _oldUserInfo.nickName;
    _maxTextLength = 16;
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"设置"];
}

- (void)backAction:(id)sender{
    if ([self userInfoIsChange]) {
        WS(weakSelf);
        WYAlertView *alert = [[WYAlertView alloc] initWithTitle:nil message:@"信息已修改还没保存哦！" cancelButtonTitle:@"取消" cancelBlock:^{
            [super backAction:sender];
        } okButtonTitle:@"保存" okBlock:^{
            [weakSelf affirmAction:nil];
        }];
        [alert show];
    }else{
        
        [super backAction:sender];
    }
}

-(BOOL)userInfoIsChange{
    BOOL isNickNameChange = (![_nickNameTextField.text isEqualToString:_oldUserInfo.nickName]);
    if (isNickNameChange || _avatarImage || _recommendUserHeadPic.length > 0) {
        return YES;
    }
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - KeyboardNotification
-(void) keyboardWillShow:(NSNotification *)note{
    
    if (_bViewDisappear) {
        return;
    }
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect supViewFrame = _personalContainerView.frame;
    float gapHeight = keyboardBounds.size.height - (self.view.bounds.size.height - supViewFrame.origin.y - supViewFrame.size.height);
    BOOL isMove = (gapHeight > 0);
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if (isMove) {
        supViewFrame.origin.y -= gapHeight;
        _personalContainerView.frame = supViewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if (_bViewDisappear) {
        return;
    }
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    
    CGRect supViewFrame = _personalContainerView.frame;
    supViewFrame.origin.y = 64;
    _personalContainerView.frame = supViewFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - custom
-(void)refreshUI{
    
    self.nickNameTextField.font = SKIN_FONT_FROMNAME(12);
    self.nickNameTextField.textColor = SKIN_TEXT_COLOR1;
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.affirmButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.affirmButton.backgroundColor = SKIN_COLOR;
    self.affirmButton.layer.cornerRadius = 4;
    self.affirmButton.layer.masksToBounds = YES;
    
    if (_avatarImage) {
        [self.avatarImageView setImage:_avatarImage];
    }else if (_recommendUserHeadPic.length > 0){
        NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[[WYEngine shareInstance] baseImgUrl],_recommendUserHeadPic]];
        [self.avatarImageView sd_setImageWithURL:headUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon"]];
    }else{
        [self.avatarImageView sd_setImageWithURL:[WYEngine shareInstance].userInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon"]];
    }
}

- (IBAction)albumAction:(id)sender{
    AvatarListViewController *avatarListVc = [[AvatarListViewController alloc] init];
    avatarListVc.delagte = self;
    [self.navigationController pushViewController:avatarListVc animated:YES];
//    __weak PersonalEditViewController *weakSelf = self;
//    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"设置%@",@"头像"] actionBlock:^(NSInteger buttonIndex) {
//        if (2 == buttonIndex) {
//            return;
//        }
//        
//        [weakSelf doActionSheetClickedButtonAtIndex:buttonIndex];
//    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", @"拍一张", nil];
//    [sheet showInView:self.view];
}
- (IBAction)affirmAction:(id)sender{
    
    _nickNameTextField.text = [_nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_nickNameTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"输个昵称吧~~"];
        return;
    }
    if ([self userInfoIsChange]) {
        [self editUserInfo];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)editUserInfo{
    NSMutableArray *dataArray = [NSMutableArray array];
    if (_avatarData) {
        QHQFormData* pData = [[QHQFormData alloc] init];
        pData.data = _avatarData;
        pData.name = @"avatar";
        pData.filename = @"avatar";
        pData.mimeType = @"image/png";
        [dataArray addObject:pData];
    }else{
        dataArray = nil;
    }
    
    [WYProgressHUD AlertLoading:@"资料修改中..." At:self.view];
    __weak PersonalEditViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] editUserInfoWithUid:[WYEngine shareInstance].uid nickName:_nickNameTextField.text avatar:dataArray userHead:_recommendUserHeadPic qqNumber:nil sex:nil realName:nil idCard:nil tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"更新失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"更新成功." At:weakSelf.view];
        
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        WYUserInfo *userInfo = [[WYUserInfo alloc] init];
        [userInfo setUserInfoByJsonDic:object];
        [WYEngine shareInstance].userInfo = userInfo;
        
        [weakSelf performSelector:@selector(editFinished) withObject:nil afterDelay:1.0];
        
    }tag:tag];
}

-(void)editFinished{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == buttonIndex ) {
        //检查设备是否有相机功能
        if (![AVCamUtilities userCameraIsUsable]) {
            [WYUIUtils showAlertWithMsg:[WYUIUtils documentOfCameraDenied]];
            return;
        }
        //判断ios7用户相机是否打开
        if (![AVCamUtilities userCaptureIsAuthorization]) {
            [WYUIUtils showAlertWithMsg:[WYUIUtils documentOfAVCaptureDenied]];
            return;
        }
    }
    
    WYImagePickerController *picker = [[WYImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    {
        UIImage* imageAfterScale = image;
        if (image.size.width != image.size.height) {
            CGSize cropSize = image.size;
            cropSize.height = MIN(image.size.width, image.size.height);
            cropSize.width = MIN(image.size.width, image.size.height);
            imageAfterScale = [image imageCroppedToFitSize:cropSize];
        }
        _avatarImage = imageAfterScale;
        NSData* imageData = UIImageJPEGRepresentation(imageAfterScale, WY_IMAGE_COMPRESSION_QUALITY);
        _avatarData = imageData;
        [self refreshUI];
    }
    [picker dismissModalViewControllerAnimated:YES];
    //    [LSCommonUtils saveImageToAlbum:picker Img:image];
    
}

#pragma mark - AvatarListViewControllerDelegate
- (void)avatarListViewControllerWith:(AvatarListViewController*)vc selectAvatarId:(NSString *)selectAvatarId avatarImage:(UIImage*)avatarImage avatarData:(NSData*)avatarData{
    
    [vc.navigationController popViewControllerAnimated:YES];
    _recommendUserHeadPic = selectAvatarId;
    _avatarImage = avatarImage;
    _avatarData = avatarData;
    [self refreshUI];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    if (!string.length && range.length > 0) {
        return YES;
    }
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    int newLength = [WYCommonUtils getHanziTextNum:newString];
    if(newLength >= _maxTextLength && textField.markedTextRange == nil) {
        _nickNameTextField.text = [WYCommonUtils getHanziTextWithText:newString maxLength:_maxTextLength];
        return NO;
    }
    return YES;
}
- (void)checkTextChaneg:(NSNotification *)notif
{
    if (_nickNameTextField.markedTextRange != nil) {
        return;
    }
    
    if ([WYCommonUtils getHanziTextNum:_nickNameTextField.text] > _maxTextLength && _nickNameTextField.markedTextRange == nil) {
        _nickNameTextField.text = [WYCommonUtils getHanziTextWithText:_nickNameTextField.text maxLength:_maxTextLength];
    }
}
@end
