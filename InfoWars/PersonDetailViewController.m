//
//  PersonDetailViewController.m
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "PersonDetailViewController.h"

@interface PersonDetailViewController ()

@end

@implementation PersonDetailViewController

@synthesize person,fnameLabel,snameLabel,ageLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadObject:(NSObject *)object {}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.fnameLabel.text = self.person.fname;
    self.snameLabel.text = self.person.sname;
    //self.ageLabel.text = [NSString stringWithFormat:@"%i",self.person.age];
    
    [self.view setBackgroundColor:[UIColor redColor]];//person.favoriteColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
