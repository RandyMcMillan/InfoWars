//
//  ViewController.m
//  InfoWars
//
//  Created by Randy McMillan on 8/9/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController () {

IBOutlet UIButton *watchNow;

}

@property (nonatomic,readwrite) NSString *movieURLString;
@property (nonatomic,readwrite) UIButton *watchNow;

@end

@implementation ViewController
@synthesize watchNow;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startReach];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)startReach {



    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * rightBrainReach = [Reachability reachabilityWithHostname:@"http://rightbrainmedia.mpl.miisolutions.net"];
    
    rightBrainReach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //[playButton setTitle:@"Play" forState:UIControlStateNormal];
                        [self.watchNow setTitle:@"Watch Now" forState:UIControlStateNormal];
        });
    };
    
    rightBrainReach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
                        [self.watchNow setTitle:@"Connect to WIFI" forState:UIControlStateNormal];
        });
    };
    
    [rightBrainReach startNotifier];
}


-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        //[self.watchNow setTitle:@"tite" forState:UIControlStateNormal];
    }
    else
    {
        //[self.watchNow setTitle:@"tite" forState:UIControlStateNormal];
    }
}


-(IBAction)playVideoStream:(id)sender {

    self.movieURLString =
    @"http://rightbrainmedia.mpl.miisolutions.net/rightbrainmedia-originpull-2/_definst_/mp4:247daily1/playlist.m3u8";
    [self loadVideo];

}

-(IBAction)displayWebPage:(id)sender {

    



}

-(void)loadVideo {

    NSURL *movieURL = [NSURL URLWithString:self.movieURLString];
    
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    //moviePlayer.supportedInterfaceOrientations = (UIInterfaceOrientationPortrait & UIInterfaceOrientationMaskLandscape);
	[self presentMoviePlayerViewControllerAnimated:moviePlayer];



}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
