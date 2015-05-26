//
//  WYImagePickerController.m
//  WangYu
//
//  Created by KID on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYImagePickerController.h"
#import "WYSettingConfig.h"
#import "AVCamCaptureManager.h"

@interface WYImagePickerController ()

@end

@implementation WYImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [[UINavigationBar appearance] setBarTintColor:SKIN_COLOR];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    } else {
        [[UINavigationBar appearance] setTintColor:SKIN_COLOR];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self prefersStatusBarHidden];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
    }
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //恢复上次的相机状态
        UIImagePickerControllerCameraFlashMode flashModel = [[WYSettingConfig staticInstance] systemCameraFlashStatus];
        if (flashModel < UIImagePickerControllerCameraFlashModeOff || flashModel > UIImagePickerControllerCameraFlashModeOn) {
            flashModel = UIImagePickerControllerCameraFlashModeAuto;
        }
        [self setCameraFlashMode:flashModel];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //记录当前的相机状态
        UIImagePickerControllerCameraFlashMode flashModel = [self cameraFlashMode];
        //    NSLog(@"flashModel = %d", flashModel);
        //ios7.1系统存在bug,cameraFlashMode无法获取。只能用AVCaptureDevice识别
        
        Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
        if (captureDeviceClass != nil) {
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            [device lockForConfiguration:nil];
            if ([device hasFlash]) {
                if (device.flashMode ==  AVCaptureFlashModeAuto) {
                    flashModel = UIImagePickerControllerCameraFlashModeAuto;
                }else if (device.flashMode ==  AVCaptureFlashModeOn) {
                    flashModel = UIImagePickerControllerCameraFlashModeOn;
                }else if (device.flashMode ==  AVCaptureFlashModeOff) {
                    flashModel = UIImagePickerControllerCameraFlashModeOff;
                }
            }
            [device unlockForConfiguration];
        }
        
        [[WYSettingConfig staticInstance] setSystemCameraFlashStatus:flashModel];
    }
    [super viewDidDisappear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        return YES;
    }
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
