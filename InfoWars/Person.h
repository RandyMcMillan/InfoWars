//
//  Person.h
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (strong) NSString *fname;
@property (strong) NSString *sname;
@property (strong) UIColor *favoriteColor;
@property int				*age;

- (id)initWithFname:(NSString *)aFname sname:(NSString *)aSname color:(UIColor *)col age:(int)aAge;


@end
