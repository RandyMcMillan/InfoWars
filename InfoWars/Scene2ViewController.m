//
//  Scene2ViewController.m
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "Scene2ViewController.h"

@interface Scene2ViewController (){

    
    IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView	*myIndicator;

}

@property (strong) IBOutlet UIWebView *webView;
@property (strong) UIActivityIndicatorView *myIndicator;

@end

@implementation Scene2ViewController

@synthesize webView,myIndicator;

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
   	self.myIndicator.alpha = 1.0;
	[self.myIndicator startAnimating];
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
	[self.myIndicator stopAnimating];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//Further error handling refs
///https://github.com/ardalahmet/UIWebViewHttpStatusCodeHandling/
// UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"webViewDidStartLoad");
	self.myIndicator.hidden = FALSE;
    self.myIndicator.alpha = 1.0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"webViewDidFinishLoad");
	self.myIndicator.hidden = TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"webView error %@", error);
    
	[UIActivityIndicatorView	animateWithDuration :3.0
                                delay				:0.5
                                options				:UIViewAnimationCurveEaseInOut
                                animations			:^{
                                        self.myIndicator.alpha = 0.0;
                                    }
     
                                    completion			:^(BOOL finished) {
                                        self.myIndicator.hidden = TRUE;
                                    }
     
     ];
    
	//    self.myIndicator.hidden = TRUE;
    
	/*
	 *   UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:@"Connection error"
	 *                                                     message:@"error" delegate:self
	 *                                                     cancelButtonTitle:@"OK"
	 *                                                     otherButtonTitles:nil];
	 *   [connectionError show];
	 */
}



@end
