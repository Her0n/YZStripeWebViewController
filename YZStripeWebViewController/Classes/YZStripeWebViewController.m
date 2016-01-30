//
//  YZStripeWebViewController.m
//  YZStripeWebViewController
//
//  Created by Yifei Zhou on 1/31/16.
//  Copyright © 2016 Yifei Zhou. All rights reserved.
//

#import "YZStripeWebViewController.h"
#import "YZStripeWebViewControllerUtils.h"

/**
 *  Visit https://stripe.com/docs/checkout#integration-simple for latest html template
 */
static NSString *stripeWebTemplateContent = @"<!DOCTYPE html>\n"
                                            @"<html>\n"
                                            @"<head>\n"
                                            @"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"
                                            @"<title>Stripe</title>\n"
                                            @"<style type=\"text/css\">\n"
                                            @"body {\n"
                                            @"background-color: transparent;\n"
                                            @"}\n"
                                            @"form {\n"
                                            @"margin-top: -100px;\n"
                                            @"}\n"
                                            @"</style>\n"
                                            @"</head>\n"
                                            @"<body>\n"
                                            @"<form action=\"/create_payment\" method=\"POST\" id=\"stripe_form\">\n"
                                            @"<script\n"
                                            @"src=\"https://checkout.stripe.com/checkout.js\" class=\"stripe-button\"\n"
                                            @"data-key={{STRIPEAPIKEY}}\n"
                                            @"data-image=\"/square-image.png\"\n"
                                            @"data-name=\"{{PRODUCTNAME}}\"\n"
                                            @"data-description=\"{{PRODUCTDESC}}\"\n"
                                            @"data-amount=\"{{PRODUCTPRICE}}\"\n"
                                            @"data-currency=\"{{PRODUCTCURRENCY}}\"\n"
                                            @"data-locale=\"auto\"\n"
                                            @"data-alipay=\"true\">\n"
                                            @"</script>\n"
                                            @"</form>\n"
                                            @"</body>\n"
                                            @"</html>";

static NSString *token;

@interface YZStripeWebViewController () <UIWebViewDelegate>

@property (readwrite, strong, nonatomic) UIWebView *webView;

@property (assign, nonatomic) YZStripeWebViewControllerStatus status;

@property (strong, nonatomic) NSDictionary *paymentResult;

@property (strong, nonatomic) NSError *lastError;

@end

@implementation YZStripeWebViewController

+ (void)registerWithToken:(NSString *)stripeToken
{
    token = stripeToken;
}

- (instancetype)initWithProductName:(NSString *)productName
                        description:(NSString *)productDescription
                              price:(NSNumber *)productPrice
                           currency:(NSString *)productCurrency
{
    // Register with token first
    if (![token isKindOfClass:[NSString class]] || [token isEqualToString:@""]) {
        NSAssert(NO, @"%@ should be registered with token first!", NSStringFromClass([self class]));
        return nil;
    }

    self = [super init];
    if (self) {
        _productName = [productName copy];
        _productDescription = [productDescription copy];
        _productPrice = [productPrice copy];
        _productCurrency = [productCurrency copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    [self _yz_setupInterface];

    NSString *htmlContent = [stripeWebTemplateContent copy];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"{{STRIPEAPIKEY}}" withString:token]; // pk_test_kUKlLlyGEeH9i1XVZXxSOJ9a
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"{{PRODUCTNAME}}" withString:self.productName ?: @""];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"{{PRODUCTDESC}}" withString:self.productDescription ?: @""];
    htmlContent =
        [htmlContent stringByReplacingOccurrencesOfString:@"{{PRODUCTPRICE}}"
                                               withString:[NSString stringWithFormat:@"%zd", (NSInteger)(floor(self.productPrice.doubleValue * 100))]];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"{{PRODUCTCURRENCY}}" withString:self.productCurrency];

    { // Setup webView
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.opaque = NO;
        self.webView.delegate = self;
    }

    [self.webView loadHTMLString:htmlContent baseURL:nil];

    self.status = YZStripeWebViewControllerStatus_Init;
}

- (void)_yz_setupInterface
{
    [self.view addSubview:self.webView];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    }
    return _webView;
}

#pragma mark - JS actions

- (void)clickPayButton
{
    NSString *js = @"document.getElementsByClassName('stripe-button-el')[0].click()";
    [self.webView stringByEvaluatingJavaScriptFromString:js];

    self.status = YZStripeWebViewControllerStatus_PayFormPresented;
}

- (void)focusEmailField
{
    NSString *js = @"document.getElementsByClassName('stripe_checkout_app')[0].contentWindow.document.getElementById('email').focus()";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark -

- (void)setStatus:(YZStripeWebViewControllerStatus)status
{
    _status = status;

    if (status == YZStripeWebViewControllerStatus_Init) {
        [self showHUD];
    } else if (status == YZStripeWebViewControllerStatus_LoadingFailed || self.status == YZStripeWebViewControllerStatus_UnkownStatus) {
        [self failedWithError:self.lastError];
    } else if (status == YZStripeWebViewControllerStatus_PayButtonLoaded) {
        [self hideHUD];

        [self clickPayButton];
    } else if (status == YZStripeWebViewControllerStatus_PayFormPresented) {
        //        [self performSelector:@selector(focusEmailField) withObject:nil afterDelay:0.3];
        //        [self focusEmailField];
    } else if (status == YZStripeWebViewControllerStatus_PayFormClosed) {
        [self canceled];
    } else if (status == YZStripeWebViewControllerStatus_PaySuccess) {
        [self successWithResult:self.paymentResult];
    }
}

- (void)showHUD
{
    // Subclass this to create your own HUD
    NSLog(@"%s called!", __PRETTY_FUNCTION__);
}

- (void)hideHUD
{
    // Subclass this to create your own HUD
    NSLog(@"%s called!", __PRETTY_FUNCTION__);
}

- (void)successWithResult:(NSDictionary *)result
{
    [self dismissWithCompletionBlock:^() {
      if (self.completionBlock) {
          self.completionBlock(result);
      }

      [self cleanup];
    }];
}

- (void)failedWithError:(NSError *)error
{
    [self dismissWithCompletionBlock:^() {
      if (self.failedBlock) {
          self.failedBlock(error);
      }

      [self cleanup];
    }];
}

- (void)canceled
{
    [self dismissWithCompletionBlock:^() {
      if (self.canceledBlock) {
          self.canceledBlock();
      }

      [self cleanup];
    }];
}

- (void)dismissWithCompletionBlock:(void (^)())completionBlock
{
    [self dismissViewControllerAnimated:YES completion:completionBlock];
}

- (void)cleanup
{
    self.completionBlock = nil;
    self.failedBlock = nil;
    self.canceledBlock = nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = YES;

    NSString *requestURLStr = request.URL.absoluteString;
    NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];

    {
        //        NSLog(@"--------------------------");
        //        NSLog(@"%@", requestURLStr);
        //        NSLog(@"%@", bodyString);
        //        NSLog(@"++++++++++++++++++++++++++");
    }

    if ([requestURLStr containsString:@"about:blank"]) {
        // Do nothing
    } else if ([requestURLStr containsString:@"checkout.stripe.com"]) { // load pay button or close pay form
        if (self.status == YZStripeWebViewControllerStatus_Init) {
            self.status = YZStripeWebViewControllerStatus_LoadingPayButton;
        } else if (self.status == YZStripeWebViewControllerStatus_PayFormPresented) {
            self.status = YZStripeWebViewControllerStatus_PayFormClosed;
        } else {
            self.status = YZStripeWebViewControllerStatus_UnkownStatus;
            shouldStartLoad = NO;
        }
    } else if ([requestURLStr containsString:@"create_payment"]) { // Got token
        if ([bodyString containsString:@"stripeToken"]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSArray *components = [bodyString componentsSeparatedByString:@"&"];
            for (NSString *component in components) {
                NSArray *keyAndValue = [component componentsSeparatedByString:@"="];
                if (keyAndValue.count == 2) {
                    dict[keyAndValue[0]] = keyAndValue[1];
                } else {
                    self.status = YZStripeWebViewControllerStatus_UnkownStatus;
                    shouldStartLoad = NO;
                    break;
                }
            }

            NSLog(@"dict: \n%@", dict);

            self.paymentResult = dict;

            self.status = YZStripeWebViewControllerStatus_PaySuccess;

            shouldStartLoad = NO; // Already got the token, no need to load anymore
        } else {
            self.status = YZStripeWebViewControllerStatus_UnkownStatus;
            shouldStartLoad = NO;
        }
    } else {
        self.status = YZStripeWebViewControllerStatus_UnkownStatus;
        shouldStartLoad = NO;
    }

    return shouldStartLoad;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.status == YZStripeWebViewControllerStatus_LoadingPayButton) {
        self.status = YZStripeWebViewControllerStatus_PayButtonLoaded;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    self.lastError = error;
    self.status = YZStripeWebViewControllerStatus_LoadingFailed;
}

#pragma mark - Present

- (void)showOnViewController:(UIViewController *)viewController
{
    [self showOnViewController:viewController animated:YES];
}

- (void)showOnViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController presentViewController:self animated:animated completion:nil];
}

- (void)show
{
    [[UIApplication sharedApplication].pr_topWindow.pr_topViewController presentViewController:self animated:YES completion:nil];
}

@end