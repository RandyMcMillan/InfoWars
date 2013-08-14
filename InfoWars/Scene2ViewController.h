//
//  Scene2ViewController.h
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Scene2ViewController : UIViewController <UIWebViewDelegate>


- (IBAction)cancel:(id)sender;
-(void)loadURL:(NSString *)string;

@end
