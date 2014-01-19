//
//  WebViewViewController.m
//  ishangbolin
//
//  Created by wenzhili on 14-1-16.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import "WebViewViewController.h"
#import "WebViewJavascriptBridge.h"

@interface WebViewViewController ()
@property WebViewJavascriptBridge* bridge;
@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSString *url=@"http://162.243.231.159:3000/ngapp/dist";
    NSString *url = @"http://192.168.0.104:3000/ngapp/app";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.mainwebview loadRequest:request];
    
	// webview init only once!
    if (_bridge) { return; }
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_mainwebview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    //*** prepare for javascript callback! ***
    [_bridge registerHandler:@"getFavorites" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"getFavorites called: %@", data);
        //TODO, fetch database data and send to callback below!
        responseCallback(@"Response from getFavorites");
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"load ing");
    [self.loading startAnimating];
    self.loading.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finish ing");
    [self.loading stopAnimating];
    self.loading.hidden = YES;
    
    //init javascript callback for iOS
    [self.mainwebview stringByEvaluatingJavaScriptFromString:@"window.iOS = {}"];
    
}

-(void)didFailLoadWithError:(UIWebView *)webView {
    NSLog(@"loading error!");
    [self.loading stopAnimating];
    self.loading.hidden = YES;
}

- (IBAction)backClickHandler:(id)sender {
    NSLog(@"back button clicked!");
    if ([self.mainwebview canGoBack]) {
        [self.mainwebview goBack];
    }
}

- (IBAction)markClickHandler:(id)sender {
    NSLog(@"mark button clicked!");
    
    NSString *bizInfo = [self.mainwebview stringByEvaluatingJavaScriptFromString:@"doFavorite()"];
    
    //NSLog(@"string >>> %@\n\n",bizInfo);
    
    if (nil != bizInfo) {
        NSLog(@"oh, yes I got it >>> %@\n\n", bizInfo);
    }else{
        NSLog(@"oo, it's null, %@\n\n", bizInfo);
    }
    
    if ([bizInfo isKindOfClass:[NSNull class]]) {
        NSLog(@"Currently is NSNull!");
    }
    
    if ([bizInfo isEqualToString:@""]) {//blank string...
        NSLog(@"Currently is list view !");
    }else{
        
    }
    
    
}




@end
