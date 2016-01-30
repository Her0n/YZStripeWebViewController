//
//  YZStripeWebViewController.h
//  YZStripeWebViewController
//
//  Created by Yifei Zhou on 1/31/16.
//  Copyright © 2016 Yifei Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZStripeWebViewControllerStatus) {
    YZStripeWebViewControllerStatus_UnkownStatus = -10,
    YZStripeWebViewControllerStatus_LoadingFailed = -1,
    YZStripeWebViewControllerStatus_Init = 0,
    YZStripeWebViewControllerStatus_LoadingPayButton,
    YZStripeWebViewControllerStatus_PayButtonLoaded,
    YZStripeWebViewControllerStatus_PayFormPresented, // The stripe button
    YZStripeWebViewControllerStatus_PayFormClosed,
    YZStripeWebViewControllerStatus_PaySuccess,
};

typedef void (^YZStripeWebViewControllerCompletionBlock)(NSDictionary *__nonnull result);

typedef void (^YZStripeWebViewControllerFailedBlock)(NSError *__nonnull error);

typedef void (^YZStripeWebViewControllerCanceledBlock)();

NS_ASSUME_NONNULL_BEGIN

@interface YZStripeWebViewController : UIViewController

@property (nullable, copy, nonatomic) YZStripeWebViewControllerCompletionBlock completionBlock;

@property (nullable, copy, nonatomic) YZStripeWebViewControllerFailedBlock failedBlock;

@property (nullable, copy, nonatomic) YZStripeWebViewControllerCanceledBlock canceledBlock;

@property (copy, nonatomic) NSString *productName;

@property (copy, nonatomic) NSString *productDescription;

@property (copy, nonatomic) NSNumber *productPrice;

@property (copy, nonatomic) NSString *productCurrency;

@property (readonly, nonatomic) UIWebView *webView;

/**
 *  Set the stripe token
 *
 *  @param stripeToken Your publishable key (test or live).
 */
+ (void)registerWithToken:(NSString *)stripeToken;

/**
 *  Create a YZStripeWebViewController instance for charging the product
 *
 *  @param productName        The name of the product
 *  @param productDescription The description of the product
 *  @param productPrice       The price of the product
 *  @param productCurrency    The currency of the amount (3-letter ISO code). The default is USD. Reference:
 * https://support.stripe.com/questions/which-currencies-does-stripe-support
 *
 *  @return instance of YZStripeWebViewController
 */
- (instancetype)initWithProductName:(NSString *)productName
                        description:(NSString *__nullable)productDescription
                              price:(NSNumber *)productPrice
                           currency:(NSString *__nullable)productCurrency;

- (void)showOnViewController:(UIViewController *)viewController;
- (void)show;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
