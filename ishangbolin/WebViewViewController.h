//
//  WebViewViewController.h
//  ishangbolin
//
//  Created by wenzhili on 14-1-16.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *mainwebview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarks;
- (IBAction)backClickHandler:(id)sender;
- (IBAction)markClickHandler:(id)sender;

@end
