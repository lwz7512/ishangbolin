//
//  WebViewViewController.m
//  ishangbolin
//
//  Created by wenzhili on 14-1-16.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()

@end

@implementation WebViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSString *url=@"http://162.243.231.159:3000/ngapp/dist";
    NSString *url = @"http://172.168.1.168:3000/ngapp/app";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self.mainwebview loadRequest:request];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"load ing");
    [self.loading startAnimating];
    self.loading.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"finish ing");
    [self.loading stopAnimating];
    self.loading.hidden = YES;
}


- (IBAction)backClickHandler:(id)sender {
    NSLog(@"back button clicked!");
    
}

- (IBAction)markClickHandler:(id)sender {
    NSLog(@"mark button clicked!");
    
}




@end
