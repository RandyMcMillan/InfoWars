//
//  DataObject.h
//  InfoWars
//
//  Created by Randy McMillan on 8/17/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataObject : NSObject

-(void)assignURL:(NSURL *)url;
-(void)assignURL2:(NSURL *)url2;
-(void)assignString:(NSString *)string;
-(void)assignString2:(NSString *)string2;


@property (nonatomic,readwrite,retain)NSURL *url;
@property (nonatomic,readwrite,retain)NSURL *url2;
@property (nonatomic,readwrite,retain)NSString *string;
@property (nonatomic,readwrite,retain)NSString *string2;

@end
