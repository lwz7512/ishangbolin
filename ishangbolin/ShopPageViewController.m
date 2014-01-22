//
//  ShopPageViewController.m
//  ishangbolin
//
//  Created by wenzhili on 14-1-21.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import "ShopPageViewController.h"

@interface ShopPageViewController ()

@end

@implementation ShopPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@">>> opening shop page: %@", self.url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.shopView loadRequest:request];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
