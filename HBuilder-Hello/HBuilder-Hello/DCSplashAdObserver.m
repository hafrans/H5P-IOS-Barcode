//
//  DCSplashObserver.m
//  HBuilder
//
//  Created by Lin xinzheng on 2018/3/7.
//  Copyright © 2018年 DCloud. All rights reserved.
//

#import "DCSplashAdObserver.h"
#import "PDRCoreAppManager.h"
#import "DCADManager.h"


DCSplashAdObserver* g_splashObserver = NULL;

@interface DCSplashAdObserver () <DCH5ScreenAdvertisingDelegate>
@property (strong, nonatomic) DCH5ScreenAdvertising *adViewContoller;
@property (strong, nonatomic) DCADLaunch *ad;
@end

@implementation DCSplashAdObserver

+ (DCH5ScreenAdvertising*)splashAdViewController{
    DCH5ScreenAdvertising *adViewContoller = nil;
    DCADManager *adManager =[DCADManager adManager];
    DCADLaunch *ad = [adManager getLaunchAD];
    if ( ad ) {
        if(g_splashObserver == nil){
            g_splashObserver = [[DCSplashAdObserver alloc] init];
        }
        g_splashObserver.ad = ad;
        adViewContoller = [[DCH5ScreenAdvertising alloc] init];
        adViewContoller.delegate = g_splashObserver;
        [adViewContoller setAdvData:ad SplashData:adManager.adsSetting];
        g_splashObserver.adViewContoller = adViewContoller;
        [[NSNotificationCenter defaultCenter] addObserver:g_splashObserver selector:@selector(onAppSplashClose:) name:PDRCoreAppDidLoadNotificationKey object:nil];
        return adViewContoller;
    }
    return nil;
}

#pragma mark - 开屏广告

- (void)onAppSplashClose:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:g_splashObserver name:PDRCoreAppDidLoadNotificationKey object:nil];
    [self.adViewContoller showSikeButton];
}

- (void)clickedAdverType:(EDCH5ADVType)type EventData:(NSString*)actData ExtData:(NSDictionary*)extDat ADLaunch:(DCADLaunch*)adLaunch {
    if ( type == EDCH5ADVType_url ) {
    } else if ( type == EDCH5ADVType_App  ){
    }
    [[DCADManager adManager] clickLaunchAD:adLaunch];
}

- (void)advScreenCanShow {
    [[DCADManager adManager] impLaunchAD:self.ad];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[PDRCore Instance] start];
    });
}

- (BOOL)advScreenWillClose:(EDCH5ADVCloseType)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDCSplashScreenCloseEvent object:nil];
    return YES;
}

@end
