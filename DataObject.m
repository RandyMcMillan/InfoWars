//
//  DataObject.m
//  InfoWars
//
//  Created by Randy McMillan on 8/17/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "DataObject.h"

@implementation DataObject

/*
 
 
 @property (nonatomic,readwrite)NSURL *url;
 @property (nonatomic,readwrite)NSURL *url2;
 @property (nonatomic,readwrite)NSString *string;
 @property (nonatomic,readwrite)NSString *string2;

 
*/
 
-(void)assignURL:(NSURL *)url {

    self.url = url;

}



-(void)assignURL2:(NSURL *)url2 {

    self.url2 = url2;

}



-(void)assignString:(NSString *)string {

    self.string = string;

}


-(void)assignString2:(NSString *)string2 {

    self.string2 = string2;

}

@end
