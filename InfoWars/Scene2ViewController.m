//
//  Scene2ViewController.m
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "Scene2ViewController.h"

@interface Scene2ViewController (){

    
    //IBOutlet UIWebView *webView;

}

@property (weak) IBOutlet UIWebView *webView;

@end

@implementation Scene2ViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //NSURL *url = [NSURL URLWithString:@"http://3g.qq.com"];
	//NSURLRequest *request = [NSURLRequest requestWithURL:url];
	//[self.webView loadRequest:request];
    [self loadURL:@"http://infowars.com"];
}


-(void)loadURL:(NSString *)string {

    
    NSURL *url = [NSURL URLWithString:string];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];

}

- (IBAction)cancel:(id)sender {

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
