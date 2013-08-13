//
//  ContactListViewController.h
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface ContactListViewController : UITableViewController


@property NSArray *people;
@property Person *p1;
@property Person *p2;
@property Person *p3;
@property Person *p4;


- (void)loadValues;

@end
