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

@interface PersonalEditViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImage *_avatarImage;
    NSData *_avatarData;
}
@property (strong, nonatomic) IBOutlet UIView *personalContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIButton *affirmButton;
@property (strong, nonatomic) IBOutlet UITextField *nickNameTextField;

- (IBAction)albumAction:(id)sender;
- (IBAction)affirmAction:(id)sender;

@end

@implementation PersonalEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"设置"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - custom
-(void)refreshUI{
    
    self.nickNameTextField.font = SKIN_FONT_FROMNAME(12);
    self.nickNameTextField.textColor = SKIN_TEXT_COLOR2;
    
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
    }else{
        
    }
}

- (IBAction)albumAction:(id)sender{
    __weak PersonalEditViewController *weakSelf = self;
    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"设置%@",@"宝宝头像"] actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        
        [weakSelf doActionSheetClickedButtonAtIndex:buttonIndex];
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", @"拍一张", nil];
    [sheet showInView:self.view];
}
- (IBAction)affirmAction:(id)sender{
    [self editUserInfo];
}

- (void)editUserInfo{
    NSMutableArray *dataArray = [NSMutableArray array];
    if (_avatarData) {
        QHQFormData* pData = [[QHQFormData alloc] init];
        pData.data = _avatarData;
        pData.name = @"avatar";
        pData.filename = @".png";
        pData.mimeType = @"image/png";
        [dataArray addObject:pData];
    }
    
    [WYProgressHUD AlertLoading:@"修改中..." At:self.view];
    __weak PersonalEditViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] editUserInfoWithUid:[WYEngine shareInstance].uid nickName:_nickNameTextField.text avatar:dataArray tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"上传失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"上传成功." At:weakSelf.view];
        
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        WYUserInfo *userInfo = [[WYUserInfo alloc] init];
        [userInfo setUserInfoByJsonDic:object];
        
        [WYEngine shareInstance].userInfo = userInfo;
        
    }tag:tag];
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

@end
