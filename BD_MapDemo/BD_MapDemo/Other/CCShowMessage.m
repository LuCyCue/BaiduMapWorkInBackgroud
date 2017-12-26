//
//  CCShowMessage.m
//  MyVisitingCard
//
//  Created by mac on 16/7/4.
//  Copyright © 2016年 lcc. All rights reserved.
//

#import "CCShowMessage.h"

@implementation CCShowMessage



+ (void)showMessage:(NSString *)message inViewController:(UIViewController *)vc
{

    UIAlertController *alerC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
   // [alerC addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^ (UIAlertAction  *action){
      //  NSLog(@"Hello word");
    [vc presentViewController:alerC animated:YES completion:^{
        
        [NSThread sleepForTimeInterval:0.5];
        [alerC dismissViewControllerAnimated:YES completion:nil];
    }];

}

+ (void)showMessage:(NSString *)msg title:(NSString *)title inViewController:(UIViewController *)vc
{
     UIAlertController *alerC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];

    [vc presentViewController:alerC animated:YES completion:^{
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [alerC dismissViewControllerAnimated:YES completion:nil];
        });
    }];

}


+ (void)showMessage:(NSString *)msg title:(NSString *)title actions:(NSArray *)actions inViewController:(UIViewController *)vc handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alerC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    for (NSString *action in actions) {
        [alerC addAction:[UIAlertAction actionWithTitle:action  style:UIAlertActionStyleDefault handler:^ (UIAlertAction  *action){
            if (handler) {
                handler(action);
            }
            
        }]];
    }
    
   [vc presentViewController:alerC animated:YES completion:nil];
    
}




- (void)showiOS7AlertViewMessage:(NSString *)msg title:(NSString *)title action1:(NSString *)action1 action2:(NSString *)action2  handler:(CallbackBlock)block
{

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:action1 otherButtonTitles:action2, nil];
    [alert show];
    self.callbackblock = block;
}
#pragma mark -alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.callbackblock(buttonIndex);

}

@end
