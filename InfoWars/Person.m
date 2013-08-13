//
//  Person.m
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize fname,sname,age,favoriteColor;

- (id)initWithFname:(NSString *)aFname sname:(NSString *)aSname color:(UIColor *)col age:(int)aAge {

    self.fname = aFname;
    self.sname = aSname;
    self.favoriteColor = col;
    self.age = aAge;
    
    return self;
};


@end
