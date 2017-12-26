//
//  AppDelegate.m
//  BD_MapDemo
//
//  Created by mac on 2017/12/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "AppDelegate.h"
#import "BDMapKit.h"

@interface AppDelegate ()<BMKGeneralDelegate>
{
    BMKMapManager* _mapManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"eUL8SNoQLGQ5KOwTBxwNyMxL"  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
  
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark --BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        BMK_LOG(@"联网成功");
    }
    else{
        BMK_LOG(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        BMK_LOG(@"授权成功");
    }
    else {
        BMK_LOG(@"onGetPermissionState %d",iError);
    }
}

@end
