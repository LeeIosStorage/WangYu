//
//  AvatarListViewController.m
//  WangYu
//
//  Created by KID on 15/5/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "AvatarListViewController.h"
#import "WYActionSheet.h"
#import "AVCamUtilities.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "UIImageView+WebCache.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridViewCell+Extended.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"

#define ONE_IMAGE_HEIGHT  90
#define item_spacing  13

@interface AvatarListViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,GMGridViewDataSource, GMGridViewActionDelegate,UIScrollViewDelegate>
{
    float _imageWidth;
}
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) IBOutlet GMGridView *imageGridView;

@end

@implementation AvatarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _images = [[NSMutableArray alloc] init];
    
    _imageWidth = ONE_IMAGE_HEIGHT;
    _imageWidth = (SCREEN_WIDTH-12*2-item_spacing*2)/3;
    
    NSInteger spacing = item_spacing;
    _imageGridView.style = GMGridViewStyleSwap;
    _imageGridView.itemSpacing = spacing;
    _imageGridView.minEdgeInsets = UIEdgeInsetsMake(12, 12, 0, 0);
    _imageGridView.centerGrid = NO;
    _imageGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    _imageGridView.actionDelegate = self;
    _imageGridView.showsHorizontalScrollIndicator = NO;
    _imageGridView.showsVerticalScrollIndicator = NO;
    _imageGridView.dataSource = self;
    _imageGridView.scrollsToTop = NO;
    _imageGridView.delegate = self;
    
    [self getCacheHeadImages];
    [self refreshHeadImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"选择头像"];
    [self setRightButtonWithTitle:@"上传图片" selector:@selector(imagePickerAction:)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getCacheHeadImages{
    __weak AvatarListViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getHeadAvatarListWithTag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.images = [[NSMutableArray alloc] init];
            NSArray *object = [jsonRet arrayObjectForKey:@"object"];
            for (NSString *picId in object) {
                if (![picId isKindOfClass:[NSString class]]) {
                    continue;
                }
                [weakSelf.images addObject:picId];
            }
            [weakSelf.imageGridView reloadData];
        }
    }];
}

-(void)refreshHeadImages{
    __weak AvatarListViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getHeadAvatarListWithTag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        weakSelf.images = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"object"];
        for (NSString *picId in object) {
            if (![picId isKindOfClass:[NSString class]]) {
                continue;
            }
            [weakSelf.images addObject:picId];
        }
        [weakSelf.imageGridView reloadData];
        
    }tag:tag];
}

#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _images.count;
    
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return CGSizeMake(_imageWidth, _imageWidth);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        cell.contentView = imageView;
        
    }
    UIImageView* imageView = (UIImageView* )cell.contentView;
    NSString *picId = _images[index];
    NSURL *pidUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[[WYEngine shareInstance] baseImgUrl],picId]];
    [imageView sd_setImageWithURL:pidUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    return cell;
}
#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
//    WYLog(@"Did tap at index %ld", position);
    NSString *picId = _images[position];
    if ([self.delagte respondsToSelector:@selector(avatarListViewControllerWith:selectAvatarId:avatarImage:avatarData:)]) {
        [self.delagte avatarListViewControllerWith:self selectAvatarId:picId avatarImage:nil avatarData:nil];
    }
}

-(void)imagePickerAction:(id)sender{
    __weak AvatarListViewController *weakSelf = self;
    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        
        [weakSelf doActionSheetClickedButtonAtIndex:buttonIndex];
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", @"拍一张", nil];
    [sheet showInView:self.view];
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
        NSData* imageData = UIImageJPEGRepresentation(imageAfterScale, WY_IMAGE_COMPRESSION_QUALITY);
        if ([self.delagte respondsToSelector:@selector(avatarListViewControllerWith:selectAvatarId:avatarImage:avatarData:)]) {
            [self.delagte avatarListViewControllerWith:self selectAvatarId:nil avatarImage:imageAfterScale avatarData:imageData];
        }
    }
    [picker dismissModalViewControllerAnimated:YES];
}

@end
