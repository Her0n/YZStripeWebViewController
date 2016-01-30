//
//  ViewController.m
//  YZStripeWebViewController
//
//  Created by Yifei Zhou on 1/31/16.
//  Copyright © 2016 Yifei Zhou. All rights reserved.
//

#import "ViewController.h"
#import "YZStripeWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = [NSString stringWithFormat:@"%@Demo", NSStringFromClass([self class])];

    [YZStripeWebViewController registerWithToken:@"pk_test_6pRNASCoBOKtIshFeQd4XMUh"];
}

- (IBAction)payButtonClicked:(id)sender
{
    YZStripeWebViewController *stripeViewController =
        [[YZStripeWebViewController alloc] initWithProductName:@"Demo Site" description:@"2 widgets ($20.00)" price:@(20.00) currency:@"USD"];

    stripeViewController.completionBlock = ^(NSDictionary *result) {
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Payment Result"
                                                                               message:[NSString stringWithFormat:@"%@", result]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
      [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    };

    stripeViewController.failedBlock = ^(NSError *error) {
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Payment Error"
                                                                               message:[NSString stringWithFormat:@"%@", error]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
      [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    };

    stripeViewController.canceledBlock = ^() {
      UIAlertController *alertController =
          [UIAlertController alertControllerWithTitle:@"Payment Canceled" message:nil preferredStyle:UIAlertControllerStyleAlert];
      [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    };

    [stripeViewController show];
}

@end
