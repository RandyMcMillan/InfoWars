//
//  ViewController.m
//  InfoWars
//
//  Created by Randy McMillan on 8/9/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,readwrite) NSString *movieURLString;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}



-(IBAction)playVideoStream:(id)sender {

    self.movieURLString =
    @"http://rightbrainmedia.mpl.miisolutions.net/rightbrainmedia-originpull-2/_definst_/mp4:247daily1/playlist.m3u8";
    [self loadVideo];

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
