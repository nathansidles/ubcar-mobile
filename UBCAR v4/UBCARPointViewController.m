//
//  UBCARPointViewController.m
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/19/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "UBCARPointViewController.h"

@interface UBCARPointViewController ()

@end

@implementation UBCARPointViewController

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Add code to load web content in UIWebView
    NSString* pointID = [@(self.idNumber) stringValue];
    NSMutableString* urlString = [[NSMutableString alloc] initWithString: @"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_point_view="];
    [urlString appendString:pointID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
