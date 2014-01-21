//
//  WebViewViewController.m
//  ishangbolin
//
//  Created by wenzhili on 14-1-16.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import "WebViewViewController.h"
#import "WebViewJavascriptBridge.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "Favorite.h"
#import "JSONKit.h"
#import "Toast+UIView.h"


@interface WebViewViewController ()
@property WebViewJavascriptBridge* bridge;
@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSString *url=@"http://162.243.231.159:3000/ngapp/dist";
    NSString *url = @"http://172.168.1.41:3000/ngapp/app";
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
        //fetch database data and send to callback below!
        NSString *json = [self objsToJson:[self getFavorites]];
        responseCallback(json);
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
    
    //call javascript function...
    NSString *bizInfo = [self.mainwebview stringByEvaluatingJavaScriptFromString:@"doFavorite()"];
    
    //NSLog(@"string >>> %@\n\n",bizInfo);
    
    if (nil != bizInfo) {
        Favorite *fav = [self jsonToObj:bizInfo];
        BOOL exist = [self checkExist:fav.business_id];
        if (!exist) {
            [self insertFavorite:fav];
        }
        
        [self.view makeToast:@"收藏成功！"];//popup message!
        NSLog(@">>> favorite saved!");
        
    }else{
        NSLog(@"oo, it's null, %@\n\n", bizInfo);
    }
    
    if ([bizInfo isKindOfClass:[NSNull class]]) {
        NSLog(@"Currently is NSNull!");
    }
    
    if ([bizInfo isEqualToString:@""]) {//blank string...
        NSLog(@"Currently is list view !");
    }
    
}//end of markClickHandler


-(NSMutableArray *) getFavorites {
    
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM favorites"];
    
    while([results next]) {
        Favorite *fav = [[Favorite alloc] init];
        fav.name = [results stringForColumn:@"name"];
        fav.business_id = [results stringForColumn:@"business_id"];
        fav.s_photo_url = [results stringForColumn:@"s_photo_url"];
        fav.categories = [results stringForColumn:@"categories"];
        fav.rating_s_img_url = [results stringForColumn:@"rating_s_img_url"];
        fav.address = [results stringForColumn:@"address"];
        fav.telephone = [results stringForColumn:@"telephone"];
        fav.longitude = [results stringForColumn:@"longitude"];
        fav.latitude = [results stringForColumn:@"latitude"];
        fav.create_time = [results intForColumn:@"create_time"];
        
        [favorites addObject:fav];
        
    }
    
    [db close];
    
    return favorites;
    
}//end of getFavorites


-(void) insertFavorite: (Favorite *) fav {
    FMDatabase *database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    NSString *sql = @"INSERT INTO favorites (name, business_id, s_photo_url, categories, rating_s_img_url, address, telephone, longitude, latitude, create_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    [database open];
    [database executeUpdate:sql, fav.name, fav.business_id, fav.s_photo_url, fav.categories, fav.rating_s_img_url, fav.address, fav.telephone, fav.longitude, fav.latitude, [NSNumber numberWithInt:fav.create_time]];
    [database close];
    
}//end of insertFavorite


-(BOOL) checkExist: (NSString *) bizId {
    FMDatabase *database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    FMResultSet *s = [database executeQuery:@"SELECT COUNT(*) FROM favorites WHERE business_id = ?", bizId];
    if ([s intForColumnIndex:0]) {
        return true;
    }else{
        return false;
    }
}


//favorites object serialize...
- (NSString *) objsToJson: (NSMutableArray *) favos {
    NSString *json = [favos JSONString];
    return json;
}

//json string deserialize...
- (Favorite *) jsonToObj: (NSString *) json {
    
    id parsedJSON = [json objectFromJSONString];
    
    Favorite *fav = [[Favorite alloc] init];
    fav.name = [parsedJSON valueForKey:@"name"];
    fav.business_id = [parsedJSON valueForKey:@"business_id"];
    fav.s_photo_url = [parsedJSON valueForKey:@"s_photo_url"];
    fav.categories = [parsedJSON valueForKey:@"categories"];
    fav.rating_s_img_url = [parsedJSON valueForKey:@"rating_s_img_url"];
    fav.address = [parsedJSON valueForKey:@"address"];
    fav.telephone = [parsedJSON valueForKey:@"telephone"];
    fav.longitude = [parsedJSON valueForKey:@"longitude"];
    fav.latitude = [parsedJSON valueForKey:@"latitude"];
    fav.create_time = [[parsedJSON valueForKey:@"create_time"] intValue];
    
    return fav;
}


- (NSString *) getDatabasePath{
    NSString *databaseName = @"Favorites.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    return [documentDir stringByAppendingPathComponent:databaseName];
    
}


@end
