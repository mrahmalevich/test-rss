//
//  TRItemViewController.m
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import "TRItemViewController.h"
#import "MBProgressHUD.h"

@interface TRItemViewController () <UIWebViewDelegate>

@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation TRItemViewController

#pragma mark - Initialization
- (instancetype)initWithItem:(Item *)item
{
    if (self = [super init]) {
        self.item = item;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.titleView = _activityIndicator;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_item.link]];
    [_webView loadRequest:request];
}

#pragma mark - UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
}

@end
