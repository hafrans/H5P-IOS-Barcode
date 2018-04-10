//
//  PGBarcode.h
//  libBarcode
//
//  Created by DCloud on 15/12/9.
//  Copyright © 2015年 DCloud. All rights reserved.
//
#import "PGPlugin.h"
#import "PGMethod.h"
#import "SGQRCode.h"
#import "PGBarcodeDef.h"

@interface  PGBarcode <SGQRCodeScanManagerDelegate, SGQRCodeAlbumManagerDelegate> : PGPlugin

@property (nonatomic, strong)NSString *callBackID;
@property (nonatomic, assign)BOOL scaning;
@property (nonatomic, assign)BOOL decodeImgWToFile;
@property (nonatomic, strong)NSString *decodeImgPath;
@property (nonatomic, strong) SGQRCodeScanManager *manager;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
- (void)Barcode:(PGMethod*)command;
- (void)start:(PGMethod*)command;
- (void)cancel:(PGMethod*)command;
- (void)scan:(PGMethod*)command;
- (void)QRCodeScanVC;
@end
