//
//  CCShowMessage.h
//  MyVisitingCard
//
//  Created by mac on 16/7/4.
//  Copyright © 2016年 lcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^CallbackBlock)(int buttonindex);
@interface CCShowMessage : NSObject<UIAlertViewDelegate>



@property (nonatomic, strong)  CallbackBlock callbackblock;

+ (void)showMessage:(NSString *)message inViewController:(UIViewController *)vc;

+ (void)showMessage:(NSString *)msg title:(NSString *)title inViewController:(UIViewController *)vc;

+ (void)showMessage:(NSString *)msg title:(NSString *)title actions:(NSArray *)actions inViewController:(UIViewController *)vc handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (void)showiOS7AlertViewMessage:(NSString *)msg title:(NSString *)title action1:(NSString *)action1 action2:(NSString *)action2  handler:(CallbackBlock)callbackblock;



@end
