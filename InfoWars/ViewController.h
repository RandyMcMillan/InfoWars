//
//  ViewController.h
//  InfoWars
//
//  Created by Randy McMillan on 8/11/13.
//  Copyright (c) 2013 Randy McMillan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain)UIWebView * listenNowWebView;
@property (nonatomic, retain) UIWebView *pageWebView;
@property (nonatomic,retain)UIView *pageWebViewContainer;

- (IBAction)playVideoStream:(id)sender;
- (IBAction)playAudioStream:(id)sender;
- (IBAction)stopAudioStream:(id)sender;
- (IBAction)loadWebPage:(id)sender;
- (void)loadWebPage;

@end
