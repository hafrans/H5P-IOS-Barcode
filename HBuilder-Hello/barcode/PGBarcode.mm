//
//  PGBarcode.m
//  libBarcode
//
//  Created by DCloud on 15/12/9.
//  Copyright © 2015年 DCloud. All rights reserved.
//
#import "PGBarcode.h"
#import "PTPathUtil.h"
#import "PDRToolSystemEx.h"
#import "PDRCoreWindowManager.h"
#import "PDRCommonString.h"
#import "PDRCoreAppFrame.h"
#import "H5WEEngineExport.h"
#import "SGQRCode.h"


@interface PGBarcode() <SGQRCodeScanManagerDelegate,SGQRCodeAlbumManagerDelegate>
@end

@implementation PGBarcode

@synthesize callBackID;
@synthesize scaning;
@synthesize decodeImgWToFile;
@synthesize decodeImgPath;

- (void) onAppEnterBackground {
    NSLog(@"后台");
    //[self.scanningView removeTimer];
    //[_manager cancelSampleBufferDelegate];
}

- (void) onAppEnterForeground {
   // [self.scanningView addTimer];
    //[_manager resetSampleBufferDelegate];
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.rootViewController.view.frame.size.height;
        CGFloat promptLabelW = self.rootViewController.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}

- (void)Barcode:(PGMethod*)command {
    NSArray *args = command.arguments;
    NSString *cbID = [args objectAtIndex:0];
//    NSArray *size = [args objectAtIndex:1];
//    NSArray *filters = [args objectAtIndex:2];
//    NSDictionary *styles = [args objectAtIndex:3];

    self.callBackID = cbID;
   
     NSLog(@"初始化");
   
}

- (void)start:(PGMethod*)command {
     NSLog(@"start");
    [self QRCodeScanVC];
    //[self setupQRCodeScanning];
}

- (void)QRCodeScanVC {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                           [self setupQRCodeScanning];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
                break;
            }      
            case AVAuthorizationStatusAuthorized: {
                 [self setupQRCodeScanning];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }
                
            default:
                break;
        }
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)cancel:(PGMethod*)command {
    NSLog(@"CANCEL");
    [self.scanningView removeTimer];
    [_manager cancelSampleBufferDelegate];
}

- (void)close:(PGMethod*)command {
    NSLog(@"CLOSE");
    [self.scanningView removeTimer];
    [_manager cancelSampleBufferDelegate];
    [self removeScanningView];
}



- (void)scan:(PGMethod*)command {
//    NSString *cbID = [command.arguments objectAtIndex:0];
//    NSString *argImgPath = [command.arguments objectAtIndex:1];
//    NSArray *filters = [command.arguments objectAtIndex:2];
//
}



- (void)dealloc {
    self.callBackID = nil;
    self.decodeImgPath = nil;
     NSLog(@"WCQRCodeScanningVC - dealloc");
    [self removeScanningView];
    [super dealloc];
}


- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.rootViewController.view.frame.size.width, self.rootViewController.view.frame.size.height*0.8)];
        _scanningView.scanningImageName = @"SGQRCode.bundle/QRCodeScanningLineGrid";
        _scanningView.scanningAnimationStyle = ScanningAnimationStyleGrid;
        _scanningView.cornerColor = [UIColor orangeColor];
    }
    return _scanningView;
}
- (void)removeScanningView {
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)setupQRCodeScanning {
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self.JSFrameContext.webEngine.scrollView];
    _manager.delegate = self;
    [self.JSFrameContext.webEngine.scrollView addSubview:self.promptLabel];
    [self.JSFrameContext.webEngine.scrollView addSubview:self.scanningView];
}

#pragma mark - - - SGQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager playSoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
//        NSLog(@"metadataObjects - - %@", metadataObjects);
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        PDRPluginResult *jsRet = [PDRPluginResult resultWithStatus:PDRCommandStatusOK
                                               messageAsDictionary:[self decodeResutWithText:obj.stringValue format:0 file:@""]];
        [jsRet setKeepCallback:YES];
        [self toCallback:self.callBackID withReslut:[jsRet toJSONString]];
        
        
        
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

- (NSDictionary*)decodeResutWithText:(NSString*)text format:(long)barcodeFormat file:(NSString*)filePath {
    return [NSDictionary dictionaryWithObjectsAndKeys:text, g_pdr_string_message,
            [NSNumber numberWithLong:barcodeFormat], g_pdr_string_type,
            filePath?filePath:[NSNull null] , g_pdr_string_file,
            nil];
}

- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue {
    if (brightnessValue < - 1) {
        //[self.view addSubview:self.flashlightBtn];
    } else {
        if (self.isSelectedFlashlightBtn == NO) {
        }
    }
}


@end
