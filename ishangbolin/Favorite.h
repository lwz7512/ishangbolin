//
//  Favorite.h
//  ishangbolin
//
//  Created by wenzhili on 14-1-20.
//  Copyright (c) 2014年 wenzhili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject{
    NSString *name;
    NSString *business_id;
    NSString *s_photo_url;
    NSString *categories;
    NSString *rating_s_img_url;
    NSString *address;
    NSString *telephone;
    NSString *longitude;
    NSString *latitude;
    int create_time;
    NSString *memo;
}

@property (nonatomic,strong)    NSString *name;
@property (nonatomic,strong)    NSString *business_id;
@property (nonatomic,strong)    NSString *s_photo_url;
@property (nonatomic,strong)    NSString *categories;
@property (nonatomic,strong)    NSString *rating_s_img_url;
@property (nonatomic,strong)    NSString *address;
@property (nonatomic,strong)    NSString *telephone;
@property (nonatomic,strong)    NSString *longitude;
@property (nonatomic,strong)    NSString *latitude;
@property (nonatomic,strong)    NSString *memo;
@property (nonatomic)           int create_time;


@end
