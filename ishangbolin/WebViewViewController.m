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
#import "ShopPageViewController.h"


@interface WebViewViewController ()
@property WebViewJavascriptBridge* bridge;
@end

@implementation WebViewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSString *url=@"http://162.243.231.159:3000/ngapp/dist";
    NSString *url = @"http://172.168.1.6:3000/ngapp/app";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.mainwebview loadRequest:request];
    
	// webview init only once!
    if (_bridge) { return; }
//    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_mainwebview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    //*** prepare for javascript callback! ***
    [_bridge registerHandler:@"getFavorites" handler:^(id data, WVJBResponseCallback responseCallback) {
        //fetch database data and send to callback below!
        NSString *json = [self dicsToJson:[self getFavorites]];
        //NSLog(@"returned favorites: %@", json);
        if (nil == json) json = @"[]";
        responseCallback(json);
    }];
    
    //*** prepare for open new view js callback! ***
    [_bridge registerHandler:@"openURL" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self openShopPageHandler: data];
    }];
    
}//end of viewDidLoad


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
    
//    [self.view makeToast:@"网页加载完成！" duration:1.0 position:@"center"];//popup message!
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
    
    if (nil != bizInfo && [bizInfo length]) {//got the biz info json string!
        
//        NSLog(@">>> to save the favorite:\n %@", bizInfo);
        
        Favorite *fav = [self jsonToObj:bizInfo];
        if (fav.business_id == nil) {
            return;
        }
        BOOL exist = [self checkExist:fav.business_id];
        if (!exist) {
            [self insertFavorite:fav];//insert the favorite shop...
            NSLog(@">>> favorite saved!");
        }
        
        [self.view makeToast:@"收藏成功！"];//popup message!
        
    }else{
        NSLog(@"oo, it's blank string, %@\n\n", bizInfo);
    }
    
    if ([bizInfo isKindOfClass:[NSNull class]]) {
        NSLog(@"Currently is NSNull!");
    }
    
    if ([bizInfo isEqualToString:@""]) {//blank string...
        NSLog(@"Currently is list view !");
    }
    
}//end of markClickHandler


- (void)openShopPageHandler:(NSString *) url {

    UIStoryboard *Main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShopPageViewController *shopage = [Main instantiateViewControllerWithIdentifier:@"shopage"];
    shopage.url = url;
    [self.navigationController pushViewController:shopage animated:true];

}


-(NSMutableArray *) getFavorites {
    
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM favorites"];
    
    
    while([results next]) {
        NSMutableDictionary *dFav = [[NSMutableDictionary alloc] init];
        
        [dFav setObject: [results stringForColumn:@"name"] forKey: @"name"];
        [dFav setObject: [results stringForColumn:@"business_id"] forKey: @"business_id"];
        [dFav setObject: [results stringForColumn:@"s_photo_url"] forKey: @"s_photo_url"];
        [dFav setObject: [results stringForColumn:@"categories"] forKey: @"categories"];
        [dFav setObject: [results stringForColumn:@"rating_s_img_url"] forKey: @"rating_s_img_url"];
        [dFav setObject: [results stringForColumn:@"address"] forKey: @"address"];
        [dFav setObject: [results stringForColumn:@"telephone"] forKey: @"telephone"];
        [dFav setObject: [results stringForColumn:@"longitude"] forKey: @"longitude"];
        [dFav setObject: [results stringForColumn:@"latitude"] forKey: @"latitude"];
        [dFav setObject: [NSNumber numberWithInt:[results intForColumn:@"create_time"]] forKey: @"create_time"];
        
        [favorites addObject:dFav];
        
    }
    
    [db close];
    
    NSLog(@">>> Total favorites length: %lu", (unsigned long)favorites.count);
    
    return favorites;
    
}//end of getFavorites


-(void) insertFavorite: (Favorite *) fav {
    FMDatabase *database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    NSString *sql = @"INSERT INTO favorites (name, business_id, s_photo_url, categories, rating_s_img_url, address, telephone, longitude, latitude, create_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    [database open];
    [database executeUpdate:sql, fav.name, fav.business_id, fav.s_photo_url, fav.categories, fav.rating_s_img_url, fav.address, fav.telephone, fav.longitude, fav.latitude, [NSNumber numberWithInt:fav.create_time]];
    [database close];
    
}//end of insertFavorite


-(BOOL) deletAll {
    FMDatabase *database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [database open];
    BOOL result = [database executeUpdate:@"DELETE FROM favorites"];
    [database close];
    
    return result;
}


-(BOOL) checkExist: (NSString *) bizId {
    FMDatabase *database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    if (bizId == nil) return true;
    
    [database open];
    
    FMResultSet *s = [database executeQuery:@"SELECT COUNT(*) FROM favorites WHERE business_id = ?", bizId];
    int totalCount = 0;
    if ([s next]) {
        totalCount = [s intForColumnIndex:0];
    }
    [database close];
    
    if (totalCount) {
        return true;
    }else{
        return false;
    }
}


//favorites object serialize...
- (NSString *) dicsToJson: (NSMutableArray *) favos {
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
