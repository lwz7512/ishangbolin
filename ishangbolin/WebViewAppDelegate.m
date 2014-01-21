//
//  WebViewAppDelegate.m
//  ishangbolin
//
//  Created by wenzhili on 14-1-16.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import "WebViewAppDelegate.h"
#import "FMDatabase.h"


@implementation WebViewAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.databaseName = @"Favorites.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
    
    [self createAndCheckDatabase];
    
    // Override point for customization after application launch.
    return YES;
}

-(void) createAndCheckDatabase
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:self.databasePath];
    
    if(success) return;//create only once....
    
    //The database is being created and stored in the documents directory.
    //You can only create, update, delete and insert data into a database in your applications documents directory in the iOS.
    //It’s the only location that allows you to edit the database.
    //If you wanted to only access data and not modify it,
    //you could store your database in the resources of your project.
    //If you are starting with an existing database that you created,
    //you need to copy the database from your resources directory to the application documents directory.
    
    //NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
    //[fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
    
    NSString *createTableSql = @"CREATE TABLE favorites (";
    createTableSql = [ createTableSql stringByAppendingString:@"id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"name TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"business_id TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"s_photo_url TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"categories TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"rating_s_img_url TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"address TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"telephone TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"longitude TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"latitude TEXT DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"create_time INTEGER DEFAULT NULL, "];
    createTableSql = [ createTableSql stringByAppendingString:@"memo TEXT DEFAULT NULL)"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:_databasePath];
    NSLog(@">>> databased created!");
    
    [database open];
    [database executeUpdate:createTableSql];
    [database close];
    
    NSLog(@">>>table ceated!");
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
