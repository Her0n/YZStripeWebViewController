//
//  UIApplication+PRTopWindow.m
//  PRAlertControllerDemo
//
//  Created by Elethom Hunter on 30/10/2014.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "YZStripeWebViewControllerUtils.h"

@implementation UIApplication (PRTopWindow)

- (UIWindow *)pr_topWindow
{
    UIWindow *topWindow = self.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *window in self.windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                topWindow = window;
                break;
            }
        }
    }
    return topWindow;
}

@end

@implementation UIWindow (PRTopViewController)

- (UIViewController *)pr_topViewController
{
    return [self pr_topViewControllerForRootViewController:self.rootViewController];
}

- (UIViewController *)pr_topViewControllerForRootViewController:(UIViewController *)rootViewController
{
    UIViewController *topViewController = rootViewController.presentedViewController ?: rootViewController;
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)topViewController;
        topViewController = navigationController.viewControllers.lastObject;
    } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)topViewController;
        topViewController = tabBarController.selectedViewController;
    }
    UIViewController *presentedViewController = topViewController.presentedViewController;
    return presentedViewController ? [self pr_topViewControllerForRootViewController:presentedViewController] : topViewController;
}

@end