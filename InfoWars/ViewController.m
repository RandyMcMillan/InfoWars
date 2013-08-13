//
//  ViewController.m
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
// #import "Scene2ViewController.h"

@interface ViewController () {
	IBOutlet UIButton	*watchNow;
	IBOutlet UIButton	*listenNow;
	IBOutlet UIWebView	*listenNowWebView;
}

@property (nonatomic, readwrite) NSString	*movieURLString;
@property (nonatomic, readwrite) UIButton	*watchNow;
@property (nonatomic, readwrite) UIButton	*listenNow;
// @property (nonatomic,readwrite) UIWebView *webView;

@end

@implementation ViewController
@synthesize watchNow, listenNow, listenNowWebView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self startReach];

	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)playVideoStream:(id)sender
{
	self.movieURLString =
		@"http://rightbrainmedia.mpl.miisolutions.net/rightbrainmedia-originpull-2/_definst_/mp4:247daily1/playlist.m3u8";
	[self loadVideo];
}

- (IBAction)playAudioStream:(id)sender
{
	NSURL			*url		= [NSURL URLWithString:@"http://www.infowars.com/stream.pls"];
	NSURLRequest	*request	= [NSURLRequest requestWithURL:url];

	[self.listenNowWebView loadRequest:request];
}

- (void)loadVideo
{
	NSURL			*url		= [NSURL URLWithString:@""];
	NSURLRequest	*request	= [NSURLRequest requestWithURL:url];

	[self.listenNowWebView loadRequest:request];

	NSURL						*movieURL		= [NSURL URLWithString:self.movieURLString];
	MPMoviePlayerViewController *moviePlayer	=
		[[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
	[self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {}

- (void)startReach
{
	[[NSNotificationCenter defaultCenter]	addObserver :self
											selector	:@selector(reachabilityChanged:)
											name		:kReachabilityChangedNotification
											object		:nil];

	Reachability *rightBrainReach =
		[Reachability reachabilityWithHostname:@"http://rightbrainmedia.mpl.miisolutions.net"];

	Reachability *infoWarsStream =
		[Reachability reachabilityWithHostname:@"http://www.infowars.com/stream.pls"];

	rightBrainReach.reachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
			});
	};

	rightBrainReach.unreachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.watchNow setTitle:@"Please Connect to WIFI" forState:UIControlStateNormal];
			});
	};

	infoWarsStream.reachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.listenNow setTitle:@"Listen Now" forState:UIControlStateNormal];
			});
	};

	infoWarsStream.unreachableBlock = ^(Reachability *reachability)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
				[self.listenNow setTitle:@"Please Connect to WIFI" forState:UIControlStateNormal];
			});
	};

	[infoWarsStream startNotifier];
	[rightBrainReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability *reach = [note object];

	if ([reach isReachable]) {
		[self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
		[self.listenNow setTitle:@"Listen Now" forState:UIControlStateNormal];
	} else {
		[self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
		[self.listenNow setTitle:@"Listen Now" forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
