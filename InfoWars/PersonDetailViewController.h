//
//  PersonDetailViewController.h
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface PersonDetailViewController : ViewController {}



@property (nonatomic,weak) IBOutlet UILabel *fnameLabel;
@property (nonatomic,weak) IBOutlet UILabel *snameLabel;
@property (nonatomic,weak) IBOutlet UILabel *ageLabel;
@property (nonatomic,weak) Person *person;


- (void)loadObject:(NSObject *)object;

@end
