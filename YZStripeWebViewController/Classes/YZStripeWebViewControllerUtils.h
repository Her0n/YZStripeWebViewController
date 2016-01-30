//
//  UIApplication+PRTopWindow.h
//  PRAlertControllerDemo
//
//  Created by Elethom Hunter on 30/10/2014.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

// https://github.com/Elethom/PRAlertController/blob/master/Classes/PRAlertControllerUtils.m

#import <UIKit/UIKit.h>

@interface UIApplication (PRTopWindow)

- (UIWindow *)pr_topWindow;

@end

@interface UIWindow (PRTopViewController)

- (UIViewController *)pr_topViewController;

@end
