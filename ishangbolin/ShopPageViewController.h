//
//  ShopPageViewController.h
//  ishangbolin
//
//  Created by wenzhili on 14-1-21.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopPageViewController : UIViewController{
    NSString * _url;
}
@property (nonatomic, strong) NSString * url;
@property (weak, nonatomic) IBOutlet UIWebView *shopView;

@end
